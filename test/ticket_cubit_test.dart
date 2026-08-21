import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_cubit.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_state.dart';

class FakeTicketRepository implements TicketRepository {
  List<TicketModel> mockTickets = [];

  @override
  Stream<List<TicketModel>> streamTickets({
    String? createdByUid,
    String? assignedToUid,
    TicketStatus? statusFilter,
  }) {
    return Stream.value(mockTickets.where((t) {
      if (createdByUid != null && t.createdBy.uid != createdByUid) return false;
      if (assignedToUid != null && t.assignedTo?.uid != assignedToUid) return false;
      if (statusFilter != null && t.status != statusFilter) return false;
      return true;
    }).toList());
  }

  @override
  Future<void> escalateTicketPriority({
    required String ticketId,
    required TicketPriority newPriority,
    required TicketPriority previousPriority,
    required int slaHours,
  }) async {
    final idx = mockTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      mockTickets[idx] = mockTickets[idx].copyWith(
        priority: newPriority,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeTicketRepository fakeRepo;
  late TicketListCubit cubit;

  final userEmployee = UserModel(
    uid: 'emp_1',
    name: 'Alice Emp',
    email: 'alice@company.com',
    role: UserRole.employee,
    createdAt: DateTime(2026, 1, 1),
  );

  final userAgentIT = UserModel(
    uid: 'agt_it',
    name: 'Bob Agent',
    email: 'bob@company.com',
    role: UserRole.agent,
    department: 'IT & Systems',
    isVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final mockTickets = [
    TicketModel(
      id: 't1',
      ticketNumber: 'HD-101',
      title: 'Email Outage',
      description: 'Outlook cannot connect',
      category: TicketCategory.it,
      priority: TicketPriority.medium,
      status: TicketStatus.open,
      createdBy: const TicketUserModel(uid: 'emp_1', name: 'Alice Emp', email: 'alice@company.com'),
      createdAt: DateTime(2026, 1, 1, 9, 0),
      updatedAt: DateTime(2026, 1, 1, 9, 0),
    ),
    TicketModel(
      id: 't2',
      ticketNumber: 'HD-102',
      title: 'Server Fire Alarm',
      description: 'Core DB down',
      category: TicketCategory.it,
      priority: TicketPriority.urgent, // Highest priority
      status: TicketStatus.open,
      createdBy: const TicketUserModel(uid: 'emp_2', name: 'Other User', email: 'other@company.com'),
      createdAt: DateTime(2026, 1, 1, 10, 0),
      updatedAt: DateTime(2026, 1, 1, 10, 0),
    ),
    TicketModel(
      id: 't3',
      ticketNumber: 'HD-103',
      title: 'Health Insurance Claim',
      description: 'Medical invoice',
      category: TicketCategory.hr,
      priority: TicketPriority.low,
      status: TicketStatus.open,
      createdBy: const TicketUserModel(uid: 'emp_1', name: 'Alice Emp', email: 'alice@company.com'),
      createdAt: DateTime(2026, 1, 1, 8, 0),
      updatedAt: DateTime(2026, 1, 1, 8, 0),
    ),
    TicketModel(
      id: 't4',
      ticketNumber: 'HD-104',
      title: 'Old Fixed Issue',
      description: 'Already closed ticket',
      category: TicketCategory.facilities,
      priority: TicketPriority.high,
      status: TicketStatus.closed,
      createdBy: const TicketUserModel(uid: 'emp_1', name: 'Alice Emp', email: 'alice@company.com'),
      createdAt: DateTime(2026, 1, 1, 7, 0),
      updatedAt: DateTime(2026, 1, 1, 7, 0),
      closedAt: DateTime(2026, 1, 1, 12, 0),
    ),
  ];

  setUp(() {
    fakeRepo = FakeTicketRepository();
    fakeRepo.mockTickets = List.from(mockTickets);
    cubit = TicketListCubit(ticketRepository: fakeRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('TicketListCubit - Role Scoping Tests', () {
    test('Employee sees only their submitted tickets', () async {
      cubit.initializeTicketStream(currentUser: userEmployee);
      await pumpEventQueue();

      final state = cubit.state as TicketListLoadedState;
      expect(state.allTickets.length, 3); // t1, t3, t4 belong to emp_1
      for (final t in state.allTickets) {
        expect(t.createdBy.uid, 'emp_1');
      }
    });

    test('Support Agent sees department tickets', () async {
      cubit.initializeTicketStream(currentUser: userAgentIT);
      await pumpEventQueue();

      final state = cubit.state as TicketListLoadedState;
      // Should see IT tickets (t1, t2)
      for (final t in state.allTickets) {
        expect(t.category, TicketCategory.it);
      }
    });
  });

  group('TicketListCubit - Sorting Order Tests (Urgent -> High -> Medium -> Low)', () {
    test('Active tickets are sorted from Urgent to Low', () async {
      cubit.initializeTicketStream(currentUser: UserModel(
        uid: 'mng_1',
        name: 'Manager',
        email: 'mng@company.com',
        role: UserRole.manager,
        createdAt: DateTime(2026, 1, 1),
      ));
      await pumpEventQueue();

      final state = cubit.state as TicketListLoadedState;
      final tickets = state.filteredTickets;

      // Active tickets should come first
      final activeTickets = tickets.where((t) => t.status == TicketStatus.open).toList();
      expect(activeTickets[0].priority, TicketPriority.urgent); // t2 (Urgent) first!
      expect(activeTickets[1].priority, TicketPriority.medium); // t1 (Medium)
      expect(activeTickets[2].priority, TicketPriority.low);    // t3 (Low)

      // Closed tickets are placed at the bottom
      expect(tickets.last.status, TicketStatus.closed);
    });
  });

  group('TicketListCubit - Filtering & Search Tests', () {
    setUp(() async {
      cubit.initializeTicketStream(currentUser: UserModel(
        uid: 'mng_1',
        name: 'Manager',
        email: 'mng@company.com',
        role: UserRole.manager,
        createdAt: DateTime(2026, 1, 1),
      ));
      await pumpEventQueue();
    });

    test('Filter by Category', () {
      cubit.filterByCategory(TicketCategory.hr);
      final state = cubit.state as TicketListLoadedState;
      expect(state.filteredTickets.length, 1);
      expect(state.filteredTickets.first.title, 'Health Insurance Claim');
    });

    test('Filter by Priority', () {
      cubit.filterByPriority(TicketPriority.urgent);
      final state = cubit.state as TicketListLoadedState;
      expect(state.filteredTickets.length, 1);
      expect(state.filteredTickets.first.title, 'Server Fire Alarm');
    });

    test('Search by query across title, description and ticket number', () {
      cubit.search('outlook');
      final state = cubit.state as TicketListLoadedState;
      expect(state.filteredTickets.length, 1);
      expect(state.filteredTickets.first.ticketNumber, 'HD-101');

      cubit.search('HD-102');
      final state2 = cubit.state as TicketListLoadedState;
      expect(state2.filteredTickets.length, 1);
      expect(state2.filteredTickets.first.title, 'Server Fire Alarm');
    });

    test('Reset filters restores full list', () {
      cubit.filterByPriority(TicketPriority.urgent);
      cubit.search('random');
      expect((cubit.state as TicketListLoadedState).filteredTickets.isEmpty, isTrue);

      cubit.resetFilters();
      expect((cubit.state as TicketListLoadedState).filteredTickets.length, 4);
    });
  });
}
