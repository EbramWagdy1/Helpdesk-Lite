import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/errors/error_handler.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/services/sla_service.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_state.dart';

class TicketListCubit extends Cubit<TicketListState> {
  final TicketRepository _ticketRepository;
  StreamSubscription<List<TicketModel>>? _ticketsSubscription;

  TicketListCubit({TicketRepository? ticketRepository})
      : _ticketRepository = ticketRepository ?? sl<TicketRepository>(),
        super(TicketListInitialState());

  static TicketListCubit get(BuildContext context) => BlocProvider.of(context);

  UserModel? _currentUser;
  List<TicketModel> _rawTickets = [];
  TicketStatus? selectedStatus;
  TicketCategory? selectedCategory;
  TicketPriority? selectedPriority;
  SlaStatus? selectedSlaStatus;
  String searchQuery = '';
  bool showOnlyAssignedToMe = false;

  void initializeTicketStream({required UserModel currentUser}) {
    _currentUser = currentUser;
    emit(TicketListLoadingState());
    _ticketsSubscription?.cancel();

    // Stream tickets according to user role
    Stream<List<TicketModel>> stream;
    if (currentUser.role == UserRole.employee) {
      // Employees only fetch their own submitted tickets
      stream = _ticketRepository.streamTickets(createdByUid: currentUser.uid);
    } else {
      // Agents & Managers fetch organization tickets from repository
      stream = _ticketRepository.streamTickets();
    }

    _ticketsSubscription = stream.listen(
      (tickets) {
        _rawTickets = tickets;
        // Check for any overdue tickets and auto-escalate in background
        SlaService.checkAndEscalateTickets(
          tickets: tickets,
          repository: _ticketRepository,
        );
        _applyFilters();
      },
      onError: (error) {
        emit(TicketListErrorState(ErrorHandler.getErrorMessage(error)));
      },
    );
  }

  void filterByStatus(TicketStatus? status) {
    selectedStatus = status;
    _applyFilters();
  }

  void filterByCategory(TicketCategory? category) {
    selectedCategory = category;
    _applyFilters();
  }

  void filterByPriority(TicketPriority? priority) {
    selectedPriority = priority;
    _applyFilters();
  }

  void filterBySlaStatus(SlaStatus? slaStatus) {
    selectedSlaStatus = slaStatus;
    _applyFilters();
  }

  void search(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void toggleAssignedToMe(bool value, String currentUid) {
    showOnlyAssignedToMe = value;
    _applyFilters();
  }

  void resetFilters() {
    selectedStatus = null;
    selectedCategory = null;
    selectedPriority = null;
    selectedSlaStatus = null;
    searchQuery = '';
    showOnlyAssignedToMe = false;
    _applyFilters();
  }

  void _applyFilters() {
    final user = _currentUser;
    List<TicketModel> scopedTickets = List.from(_rawTickets);

    // If Support Agent: Only show tickets for their department or tickets assigned to them
    if (user != null && user.role == UserRole.agent) {
      scopedTickets = scopedTickets.where((t) {
        final matchesDept = t.category.matchesDepartment(user.department);
        final isAssignedToMe = t.assignedTo?.uid == user.uid;
        return matchesDept || isAssignedToMe;
      }).toList();
    }

    List<TicketModel> filtered = List.from(scopedTickets);

    if (showOnlyAssignedToMe && user != null) {
      filtered = filtered.where((t) => t.assignedTo?.uid == user.uid).toList();
    }

    if (selectedStatus != null) {
      filtered = filtered.where((t) => t.status == selectedStatus).toList();
    }

    if (selectedCategory != null) {
      filtered = filtered.where((t) => t.category == selectedCategory).toList();
    }

    if (selectedPriority != null) {
      filtered = filtered.where((t) => t.priority == selectedPriority).toList();
    }

    if (selectedSlaStatus != null) {
      filtered = filtered.where((t) {
        final isActive = t.status == TicketStatus.open || t.status == TicketStatus.inProgress;
        return isActive && SlaService.getSlaStatus(t) == selectedSlaStatus;
      }).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.ticketNumber.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.createdBy.name.toLowerCase().contains(q);
      }).toList();
    }

    // Sort tickets: Active first, then Urgent -> High -> Medium -> Low, then newest first
    int priorityCompare(TicketModel a, TicketModel b) {
      final aActive = (a.status == TicketStatus.open || a.status == TicketStatus.inProgress);
      final bActive = (b.status == TicketStatus.open || b.status == TicketStatus.inProgress);
      if (aActive != bActive) {
        return aActive ? -1 : 1;
      }
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      return b.createdAt.compareTo(a.createdAt);
    }

    scopedTickets.sort(priorityCompare);
    filtered.sort(priorityCompare);

    emit(TicketListLoadedState(
      allTickets: scopedTickets,
      filteredTickets: filtered,
      selectedStatus: selectedStatus,
      selectedCategory: selectedCategory,
      selectedPriority: selectedPriority,
      selectedSlaStatus: selectedSlaStatus,
      searchQuery: searchQuery,
    ));
  }

  @override
  Future<void> close() {
    _ticketsSubscription?.cancel();
    return super.close();
  }
}
