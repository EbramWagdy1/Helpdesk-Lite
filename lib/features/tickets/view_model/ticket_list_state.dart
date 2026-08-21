import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/services/sla_service.dart';

abstract class TicketListState {}

class TicketListInitialState extends TicketListState {}

class TicketListLoadingState extends TicketListState {}

class TicketListLoadedState extends TicketListState {
  final List<TicketModel> allTickets;
  final List<TicketModel> filteredTickets;
  final TicketStatus? selectedStatus;
  final TicketCategory? selectedCategory;
  final TicketPriority? selectedPriority;
  final SlaStatus? selectedSlaStatus;
  final String searchQuery;

  TicketListLoadedState({
    required this.allTickets,
    required this.filteredTickets,
    this.selectedStatus,
    this.selectedCategory,
    this.selectedPriority,
    this.selectedSlaStatus,
    this.searchQuery = '',
  });
}

class TicketListErrorState extends TicketListState {
  final String errorMessage;
  TicketListErrorState(this.errorMessage);
}
