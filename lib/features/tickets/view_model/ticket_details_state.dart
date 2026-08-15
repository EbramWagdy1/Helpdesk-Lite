import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/comment_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

abstract class TicketDetailsState {}

class TicketDetailsInitialState extends TicketDetailsState {}

class TicketDetailsLoadingState extends TicketDetailsState {}

class TicketDetailsLoadedState extends TicketDetailsState {
  final TicketModel ticket;
  final List<CommentModel> comments;
  final List<UserModel> availableAgents;
  final bool isSubmittingComment;

  TicketDetailsLoadedState({
    required this.ticket,
    required this.comments,
    this.availableAgents = const [],
    this.isSubmittingComment = false,
  });
}

class TicketDetailsDeletedState extends TicketDetailsState {}

class TicketDetailsErrorState extends TicketDetailsState {
  final String errorMessage;
  TicketDetailsErrorState(this.errorMessage);
}
