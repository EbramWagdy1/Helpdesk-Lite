import 'package:helpdesk/features/tickets/model/ticket_model.dart';

abstract class TicketListState {}

class TicketListInitialState extends TicketListState {}

class TicketListLoadingState extends TicketListState {}

class TicketListLoadedState extends TicketListState {
  final List<TicketModel> allTickets;
  final List<TicketModel> filteredTickets;
  final TicketStatus? selectedStatus;
  final TicketCategory? selectedCategory;
  final TicketPriority? selectedPriority;
  final String searchQuery;

  TicketListLoadedState({
    required this.allTickets,
    required this.filteredTickets,
    this.selectedStatus,
    this.selectedCategory,
    this.selectedPriority,
    this.searchQuery = '',
  });
}

class TicketListErrorState extends TicketListState {
  final String errorMessage;
  TicketListErrorState(this.errorMessage);
}
