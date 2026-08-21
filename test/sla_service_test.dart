import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/services/sla_service.dart';

void main() {
  group('SlaService - Duration & Deadline Tests', () {
    test('Should return correct SLA duration per priority', () {
      expect(SlaService.getSlaDuration(TicketPriority.low), const Duration(hours: 48));
      expect(SlaService.getSlaDuration(TicketPriority.medium), const Duration(hours: 24));
      expect(SlaService.getSlaDuration(TicketPriority.high), const Duration(hours: 12));
      expect(SlaService.getSlaDuration(TicketPriority.urgent), const Duration(hours: 4));
    });

    test('Should compute exact target deadline based on createdAt and SLA', () {
      final created = DateTime(2026, 1, 1, 10, 0);
      final ticket = TicketModel(
        id: 't1',
        ticketNumber: 'HD-100',
        title: 'Printer Issue',
        description: 'Printer out of ink',
        category: TicketCategory.facilities,
        priority: TicketPriority.medium, // 24 hours
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      final deadline = SlaService.getTargetDeadline(ticket);
      expect(deadline, DateTime(2026, 1, 2, 10, 0));
    });
  });

  group('SlaService - Status & Breach Calculations', () {
    final created = DateTime(2026, 1, 1, 10, 0);

    test('Should return onTrack for fresh ticket with ample time remaining', () {
      final ticket = TicketModel(
        id: 't1',
        ticketNumber: 'HD-101',
        title: 'Account Unlock',
        description: 'Locked out',
        category: TicketCategory.it,
        priority: TicketPriority.medium, // 24h
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      // Current time is only 2 hours after creation (22 hours left of 24h SLA)
      final now = created.add(const Duration(hours: 2));
      final status = SlaService.getSlaStatus(ticket, now: now);
      expect(status, SlaStatus.onTrack);

      final progress = SlaService.getSlaProgress(ticket, now: now);
      expect((progress * 100).round(), (2 / 24 * 100).round());
    });

    test('Should return warning when <= 25% or <= 3 hours remaining', () {
      final ticket = TicketModel(
        id: 't2',
        ticketNumber: 'HD-102',
        title: 'Network Lag',
        description: 'Slow internet',
        category: TicketCategory.it,
        priority: TicketPriority.medium, // 24h -> warning when <= 6h (25%) or <= 3h
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      // Current time is 22 hours after creation (only 2 hours left)
      final now = created.add(const Duration(hours: 22));
      final status = SlaService.getSlaStatus(ticket, now: now);
      expect(status, SlaStatus.warning);
    });

    test('Should return breached when active ticket exceeds deadline', () {
      final ticket = TicketModel(
        id: 't3',
        ticketNumber: 'HD-103',
        title: 'Payroll Error',
        description: 'Incorrect bonus',
        category: TicketCategory.finance,
        priority: TicketPriority.medium, // 24h
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      // Current time is 26 hours after creation (2 hours overdue)
      final now = created.add(const Duration(hours: 26));
      final status = SlaService.getSlaStatus(ticket, now: now);
      expect(status, SlaStatus.breached);

      final overdue = SlaService.getOverdueDuration(ticket, now: now);
      expect(overdue.inHours, 2);
    });

    test('Should return achieved if resolved before SLA deadline', () {
      final ticket = TicketModel(
        id: 't4',
        ticketNumber: 'HD-104',
        title: 'New Mouse Request',
        description: 'Mouse broken',
        category: TicketCategory.it,
        priority: TicketPriority.low, // 48h
        status: TicketStatus.resolved,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created.add(const Duration(hours: 10)),
        resolvedAt: created.add(const Duration(hours: 10)),
      );

      final status = SlaService.getSlaStatus(ticket);
      expect(status, SlaStatus.achieved);
    });

    test('Should return breached if resolved AFTER SLA deadline', () {
      final ticket = TicketModel(
        id: 't5',
        ticketNumber: 'HD-105',
        title: 'Server Crash',
        description: 'DB offline',
        category: TicketCategory.it,
        priority: TicketPriority.urgent, // 4h
        status: TicketStatus.resolved,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created.add(const Duration(hours: 8)),
        resolvedAt: created.add(const Duration(hours: 8)), // 4h overdue
      );

      final status = SlaService.getSlaStatus(ticket);
      expect(status, SlaStatus.breached);
    });
  });

  group('SlaService - Auto-Escalation Logic', () {
    test('Next priority hierarchy progression', () {
      expect(SlaService.getNextPriority(TicketPriority.low), TicketPriority.medium);
      expect(SlaService.getNextPriority(TicketPriority.medium), TicketPriority.high);
      expect(SlaService.getNextPriority(TicketPriority.high), TicketPriority.urgent);
      expect(SlaService.getNextPriority(TicketPriority.urgent), isNull);
    });

    test('Should escalate active overdue Medium ticket to High', () {
      final created = DateTime(2026, 1, 1, 10, 0);
      final ticket = TicketModel(
        id: 't_esc_1',
        ticketNumber: 'HD-201',
        title: 'Software License',
        description: 'Adobe expired',
        category: TicketCategory.it,
        priority: TicketPriority.medium, // 24h
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      // Past 24 hours -> eligible for escalation
      final now = created.add(const Duration(hours: 25));
      expect(SlaService.shouldEscalate(ticket, now: now), isTrue);
      expect(SlaService.getNextPriority(ticket.priority), TicketPriority.high);
    });

    test('Should NOT escalate closed or resolved tickets even if past deadline', () {
      final created = DateTime(2026, 1, 1, 10, 0);
      final resolvedTicket = TicketModel(
        id: 't_esc_2',
        ticketNumber: 'HD-202',
        title: 'Desk Relocation',
        description: 'Move desk',
        category: TicketCategory.facilities,
        priority: TicketPriority.low,
        status: TicketStatus.resolved,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created.add(const Duration(hours: 50)),
      );

      final now = created.add(const Duration(hours: 60));
      expect(SlaService.shouldEscalate(resolvedTicket, now: now), isFalse);
    });

    test('Should NOT escalate Urgent tickets (max priority already reached)', () {
      final created = DateTime(2026, 1, 1, 10, 0);
      final urgentTicket = TicketModel(
        id: 't_esc_3',
        ticketNumber: 'HD-203',
        title: 'Security Breach Alarm',
        description: 'Intrusion alert',
        category: TicketCategory.it,
        priority: TicketPriority.urgent,
        status: TicketStatus.open,
        createdBy: const TicketUserModel(uid: 'u1', name: 'User 1', email: 'u1@test.com'),
        createdAt: created,
        updatedAt: created,
      );

      final now = created.add(const Duration(hours: 10));
      expect(SlaService.shouldEscalate(urgentTicket, now: now), isFalse);
    });
  });
}
