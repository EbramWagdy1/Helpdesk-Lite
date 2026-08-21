import 'dart:async';
import 'package:flutter/material.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

enum SlaStatus {
  onTrack('On Track', AppColors.success, Color(0xFFDCFCE7)),
  warning('At Risk', AppColors.warning, Color(0xFFFEF3C7)),
  breached('Breached', AppColors.error, Color(0xFFFEE2E2)),
  achieved('SLA Met', Color(0xFF0284C7), Color(0xFFE0F2FE));

  final String label;
  final Color color;
  final Color bgColor;

  const SlaStatus(this.label, this.color, this.bgColor);
}

class SlaService {
  /// Default SLA Durations per Priority
  static const Duration lowSla = Duration(hours: 48);
  static const Duration mediumSla = Duration(hours: 24);
  static const Duration highSla = Duration(hours: 12);
  static const Duration urgentSla = Duration(hours: 4);

  // In-memory set of ticket IDs currently undergoing escalation to prevent spamming
  static final Set<String> _pendingEscalations = {};

  /// Returns SLA Duration based on ticket priority
  static Duration getSlaDuration(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return lowSla;
      case TicketPriority.medium:
        return mediumSla;
      case TicketPriority.high:
        return highSla;
      case TicketPriority.urgent:
        return urgentSla;
    }
  }

  /// Calculates target deadline for the ticket
  static DateTime getTargetDeadline(TicketModel ticket) {
    final sla = getSlaDuration(ticket.priority);
    return ticket.createdAt.add(sla);
  }

  /// Calculates remaining duration until SLA breach
  static Duration getRemainingDuration(TicketModel ticket, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final deadline = getTargetDeadline(ticket);
    final diff = deadline.difference(current);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Calculates overdue duration if breached
  static Duration getOverdueDuration(TicketModel ticket, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final deadline = getTargetDeadline(ticket);
    final diff = current.difference(deadline);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Returns SLA elapsed progress between 0.0 (just created) and 1.0 (deadline reached/passed)
  static double getSlaProgress(TicketModel ticket, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final totalDuration = getSlaDuration(ticket.priority).inMilliseconds;
    if (totalDuration <= 0) return 1.0;

    final effectiveEnd = (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed)
        ? (ticket.resolvedAt ?? ticket.closedAt ?? current)
        : current;

    final elapsed = effectiveEnd.difference(ticket.createdAt).inMilliseconds;
    final progress = elapsed / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  /// Evaluates the current SLA Status of a ticket
  static SlaStatus getSlaStatus(TicketModel ticket, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final deadline = getTargetDeadline(ticket);

    // If resolved or closed
    if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) {
      final completionTime = ticket.resolvedAt ?? ticket.closedAt ?? current;
      if (completionTime.isBefore(deadline) || completionTime.isAtSameMomentAs(deadline)) {
        return SlaStatus.achieved;
      } else {
        return SlaStatus.breached;
      }
    }

    // Active ticket (Open / InProgress)
    if (current.isAfter(deadline)) {
      return SlaStatus.breached;
    }

    // Check if within warning zone (<= 25% of SLA or <= 3 hours remaining)
    final remaining = deadline.difference(current);
    final totalDuration = getSlaDuration(ticket.priority);
    if (remaining.inMinutes <= (totalDuration.inMinutes * 0.25) || remaining.inHours <= 3) {
      return SlaStatus.warning;
    }

    return SlaStatus.onTrack;
  }

  /// Gets the next escalated priority level
  static TicketPriority? getNextPriority(TicketPriority current) {
    switch (current) {
      case TicketPriority.low:
        return TicketPriority.medium;
      case TicketPriority.medium:
        return TicketPriority.high;
      case TicketPriority.high:
        return TicketPriority.urgent;
      case TicketPriority.urgent:
        return null; // Top priority already
    }
  }

  /// Determines whether an active ticket is overdue and eligible for auto-escalation
  static bool shouldEscalate(TicketModel ticket, {DateTime? now}) {
    // Only escalate active (unresolved/unclosed) tickets
    if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) {
      return false;
    }

    final current = now ?? DateTime.now();
    final deadline = getTargetDeadline(ticket);

    // If past deadline and there's a higher priority to escalate to
    return current.isAfter(deadline) && getNextPriority(ticket.priority) != null;
  }

  /// Checks tickets and performs auto-escalation in Firestore
  static Future<void> checkAndEscalateTickets({
    required List<TicketModel> tickets,
    required TicketRepository repository,
  }) async {
    final now = DateTime.now();

    for (final ticket in tickets) {
      if (shouldEscalate(ticket, now: now)) {
        if (_pendingEscalations.contains(ticket.id)) continue;

        final nextPriority = getNextPriority(ticket.priority);
        if (nextPriority == null) continue;

        _pendingEscalations.add(ticket.id);

        try {
          final slaHours = getSlaDuration(ticket.priority).inHours;
          await repository.escalateTicketPriority(
            ticketId: ticket.id,
            newPriority: nextPriority,
            previousPriority: ticket.priority,
            slaHours: slaHours,
          );
        } catch (e) {
          debugPrint('Error escalating ticket ${ticket.id}: $e');
        } finally {
          _pendingEscalations.remove(ticket.id);
        }
      }
    }
  }
}
