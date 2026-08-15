import 'package:helpdesk/features/tickets/model/ticket_model.dart';

abstract class CreateTicketState {}

class CreateTicketInitialState extends CreateTicketState {}

class CreateTicketLoadingState extends CreateTicketState {
  final double progress;
  CreateTicketLoadingState({this.progress = 0.0});
}

class CreateTicketCategoryChangedState extends CreateTicketState {
  final TicketCategory category;
  CreateTicketCategoryChangedState(this.category);
}

class CreateTicketPriorityChangedState extends CreateTicketState {
  final TicketPriority priority;
  CreateTicketPriorityChangedState(this.priority);
}

class CreateTicketAttachmentsChangedState extends CreateTicketState {
  final int count;
  CreateTicketAttachmentsChangedState(this.count);
}

class CreateTicketSuccessState extends CreateTicketState {
  final TicketModel ticket;
  CreateTicketSuccessState(this.ticket);
}

class CreateTicketErrorState extends CreateTicketState {
  final String errorMessage;
  CreateTicketErrorState(this.errorMessage);
}
