import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Should correctly parse fromMap and toMap', () {
      final user = UserModel(
        uid: 'usr_123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '01012345678',
        role: UserRole.agent,
        department: 'IT & Systems',
        createdAt: DateTime(2026, 1, 1),
      );

      final map = user.toMap();
      expect(map['name'], 'John Doe');
      expect(map['role'], 'agent');
      expect(map['department'], 'IT & Systems');

      final parsed = UserModel.fromMap(map, 'usr_123');
      expect(parsed.uid, 'usr_123');
      expect(parsed.name, 'John Doe');
      expect(parsed.role, UserRole.agent);
      expect(parsed.role.displayName, 'Support Agent');
    });

    test('Should fallback to employee role if invalid', () {
      final role = UserRole.fromString('invalid_role');
      expect(role, UserRole.employee);
    });
  });

  group('TicketModel Tests', () {
    test('Should parse TicketModel to/from Map with enums and dates', () {
      final ticket = TicketModel(
        id: 'tkt_001',
        ticketNumber: 'HD-1024',
        title: 'VPN Connection issue',
        description: 'Unable to connect to internal VPN server.',
        category: TicketCategory.it,
        priority: TicketPriority.urgent,
        status: TicketStatus.open,
        createdBy: const TicketUserModel(
          uid: 'usr_1',
          name: 'Alice Employee',
          email: 'alice@company.com',
          department: 'Engineering',
        ),
        createdAt: DateTime(2026, 1, 15, 10, 30),
        updatedAt: DateTime(2026, 1, 15, 10, 30),
      );

      final map = ticket.toMap();
      expect(map['ticketNumber'], 'HD-1024');
      expect(map['priority'], 'urgent');
      expect(map['category'], 'it');
      expect(map['status'], 'open');

      final parsed = TicketModel.fromMap(map, 'tkt_001');
      expect(parsed.id, 'tkt_001');
      expect(parsed.ticketNumber, 'HD-1024');
      expect(parsed.priority, TicketPriority.urgent);
      expect(parsed.category, TicketCategory.it);
      expect(parsed.status, TicketStatus.open);
      expect(parsed.createdBy.name, 'Alice Employee');
    });

    test('TicketStatus transition and labels', () {
      expect(TicketStatus.fromString('in_progress'), TicketStatus.inProgress);
      expect(TicketStatus.fromString('inprogress'), TicketStatus.inProgress);
      expect(TicketStatus.fromString('resolved'), TicketStatus.resolved);
      expect(TicketStatus.fromString('closed'), TicketStatus.closed);
      expect(TicketStatus.fromString('open'), TicketStatus.open);
    });
  });
}
