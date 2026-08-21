import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/features/auth/data/auth_repository.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/comment_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_details_cubit.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_details_state.dart';

class MockTicketRepository implements TicketRepository {
  TicketModel currentTicket;
  List<CommentModel> comments = [];

  MockTicketRepository(this.currentTicket);

  @override
  Stream<TicketModel?> streamTicketById(String ticketId) => Stream.value(currentTicket);

  @override
  Stream<List<CommentModel>> streamComments(String ticketId) => Stream.value(comments);

  @override
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus newStatus,
    required String performedByName,
    required String performedByRole,
  }) async {
    currentTicket = currentTicket.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      resolvedAt: newStatus == TicketStatus.resolved ? DateTime.now() : null,
      closedAt: newStatus == TicketStatus.closed ? DateTime.now() : null,
    );
  }

  @override
  Future<void> assignTicket({
    required String ticketId,
    required TicketUserModel? agent,
    required String performedByName,
    required String performedByRole,
  }) async {
    currentTicket = currentTicket.copyWith(
      assignedTo: agent,
      status: TicketStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> addComment({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    List<String> attachmentUrls = const [],
    bool isInternal = false,
  }) async {
    comments.add(CommentModel(
      id: 'c_${comments.length + 1}',
      ticketId: ticketId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      attachmentUrls: attachmentUrls,
      createdAt: DateTime.now(),
      isInternal: isInternal,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  List<UserModel> mockAgents = [];

  @override
  Future<List<UserModel>> getSupportAgents() async => mockAgents;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockTicketRepository ticketRepo;
  late MockAuthRepository authRepo;
  late TicketDetailsCubit cubit;

  final sampleTicket = TicketModel(
    id: 'tkt_detail_1',
    ticketNumber: 'HD-999',
    title: 'Monitor flickering',
    description: 'Hardware issue',
    category: TicketCategory.it,
    priority: TicketPriority.high,
    status: TicketStatus.open,
    createdBy: const TicketUserModel(uid: 'emp_1', name: 'Alice', email: 'alice@company.com'),
    createdAt: DateTime(2026, 1, 1, 10, 0),
    updatedAt: DateTime(2026, 1, 1, 10, 0),
  );

  final agent = UserModel(
    uid: 'agt_1',
    name: 'Bob Agent',
    email: 'bob@company.com',
    role: UserRole.agent,
    department: 'IT & Systems',
    isVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    ticketRepo = MockTicketRepository(sampleTicket);
    authRepo = MockAuthRepository();
    authRepo.mockAgents = [agent];
    cubit = TicketDetailsCubit(
      ticketRepository: ticketRepo,
      authRepository: authRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('TicketDetailsCubit - Workflow & Actions', () {
    test('Init loads ticket details and available agents', () async {
      cubit.init('tkt_detail_1');
      await pumpEventQueue();

      expect(cubit.state is TicketDetailsLoadedState, isTrue);
      final state = cubit.state as TicketDetailsLoadedState;
      expect(state.ticket.ticketNumber, 'HD-999');
      expect(state.ticket.status, TicketStatus.open);
      expect(state.availableAgents.length, 1);
    });

    test('Support agent claiming ticket assigns agent and updates state to inProgress', () async {
      cubit.init('tkt_detail_1');
      await pumpEventQueue();

      await cubit.claimTicket(agent);
      expect(ticketRepo.currentTicket.assignedTo?.uid, 'agt_1');
      expect(ticketRepo.currentTicket.status, TicketStatus.inProgress);
    });

    test('Resolving ticket marks status resolved and sets resolvedAt', () async {
      cubit.init('tkt_detail_1');
      await pumpEventQueue();

      await cubit.updateStatus(
        newStatus: TicketStatus.resolved,
        currentUser: agent,
      );

      expect(ticketRepo.currentTicket.status, TicketStatus.resolved);
      expect(ticketRepo.currentTicket.resolvedAt, isNotNull);
    });

    test('Adding public comment on ticket', () async {
      cubit.init('tkt_detail_1');
      await pumpEventQueue();

      await cubit.addComment(
        message: 'We are investigating this issue.',
        currentUser: agent,
      );

      expect(ticketRepo.comments.length, 1);
      expect(ticketRepo.comments.first.message, 'We are investigating this issue.');
      expect(ticketRepo.comments.first.senderName, 'Bob Agent');
    });
  });
}
