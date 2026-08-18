import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/errors/error_handler.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/features/auth/data/auth_repository.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/comment_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_details_state.dart';

class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  final TicketRepository _ticketRepository;
  final AuthRepository _authRepository;
  StreamSubscription<TicketModel?>? _ticketSubscription;
  StreamSubscription<List<CommentModel>>? _commentsSubscription;

  TicketModel? _currentTicket;
  List<CommentModel> _currentComments = [];
  List<UserModel> _availableAgents = [];

  TicketDetailsCubit({
    TicketRepository? ticketRepository,
    AuthRepository? authRepository,
  })  : _ticketRepository = ticketRepository ?? sl<TicketRepository>(),
        _authRepository = authRepository ?? sl<AuthRepository>(),
        super(TicketDetailsInitialState());

  bool isDeleting = false;

  void init(String ticketId) {
    emit(TicketDetailsLoadingState());
    _loadAgents();

    // Stream ticket details
    _ticketSubscription?.cancel();
    _ticketSubscription = _ticketRepository.streamTicketById(ticketId).listen(
      (ticket) {
        if (isDeleting) return;
        if (ticket == null) {
          emit(TicketDetailsErrorState('Ticket not found or has been removed.'));
          return;
        }
        _currentTicket = ticket;
        _emitLoaded();
      },
      onError: (err) {
        if (isDeleting) return;
        emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(err)));
      },
    );

    // Stream comments
    _commentsSubscription?.cancel();
    _commentsSubscription = _ticketRepository.streamComments(ticketId).listen(
      (comments) {
        if (isDeleting) return;
        _currentComments = comments;
        _emitLoaded();
      },
      onError: (err) {
        if (isDeleting) return;
        emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(err)));
      },
    );
  }

  Future<void> _loadAgents() async {
    try {
      _availableAgents = await _authRepository.getSupportAgents();
      _emitLoaded();
    } catch (_) {}
  }

  void _emitLoaded({bool isSubmittingComment = false}) {
    if (_currentTicket != null) {
      emit(TicketDetailsLoadedState(
        ticket: _currentTicket!,
        comments: _currentComments,
        availableAgents: _availableAgents,
        isSubmittingComment: isSubmittingComment,
      ));
    }
  }

  Future<void> updateStatus({
    required TicketStatus newStatus,
    required UserModel currentUser,
  }) async {
    if (_currentTicket == null) return;

    try {
      await _ticketRepository.updateTicketStatus(
        ticketId: _currentTicket!.id,
        newStatus: newStatus,
        performedByName: currentUser.name,
        performedByRole: currentUser.role.displayName,
      );
    } catch (e) {
      emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> claimTicket(UserModel currentUser) async {
    if (_currentTicket == null) return;

    try {
      await _ticketRepository.assignTicket(
        ticketId: _currentTicket!.id,
        agent: TicketUserModel(
          uid: currentUser.uid,
          name: currentUser.name,
          email: currentUser.email,
        ),
        performedByName: currentUser.name,
        performedByRole: currentUser.role.displayName,
      );
    } catch (e) {
      emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> assignToAgent({
    required UserModel agent,
    required UserModel currentUser,
  }) async {
    if (_currentTicket == null) return;

    try {
      await _ticketRepository.assignTicket(
        ticketId: _currentTicket!.id,
        agent: TicketUserModel(
          uid: agent.uid,
          name: agent.name,
          email: agent.email,
        ),
        performedByName: currentUser.name,
        performedByRole: currentUser.role.displayName,
      );
    } catch (e) {
      emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> addComment({
    required String message,
    required UserModel currentUser,
  }) async {
    if (_currentTicket == null || message.trim().isEmpty) return;

    _emitLoaded(isSubmittingComment: true);

    try {
      await _ticketRepository.addComment(
        ticketId: _currentTicket!.id,
        senderId: currentUser.uid,
        senderName: currentUser.name,
        senderRole: currentUser.role.displayName,
        message: message,
      );
      _emitLoaded(isSubmittingComment: false);
    } catch (e) {
      _emitLoaded(isSubmittingComment: false);
      emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> deleteTicket() async {
    if (_currentTicket == null || isDeleting) return;
    isDeleting = true;
    final ticketId = _currentTicket!.id;
    final attachments = _currentTicket!.attachmentUrls;

    // Immediately cancel Firestore subscriptions so null snapshot doesn't trigger error state
    await _ticketSubscription?.cancel();
    await _commentsSubscription?.cancel();

    emit(TicketDetailsLoadingState());
    try {
      await _ticketRepository.deleteTicket(ticketId, attachments);
      emit(TicketDetailsDeletedState());
    } catch (e) {
      isDeleting = false;
      emit(TicketDetailsErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<void> close() {
    _ticketSubscription?.cancel();
    _commentsSubscription?.cancel();
    return super.close();
  }
}
