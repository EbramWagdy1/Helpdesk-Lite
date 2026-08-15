import 'package:flutter/material.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

class TicketCardWidget extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCardWidget({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Ticket ID, Category & Priority
            Row(
              children: [
                // Ticket Number Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.ticketNumber,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Department / Category
                Icon(ticket.category.icon, size: 14, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket.category.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Priority Badge (Minimal dot + text)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ticket.priority.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.priority.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ticket.priority.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Description Snippet (if available)
            if (ticket.description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                ticket.description.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            // Bottom Footer Row
            Row(
              children: [
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ticket.status.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: ticket.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ticket.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ticket.status.color,
                        ),
                      ),
                    ],
                  ),
                ),

                if (ticket.attachmentUrls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF94A3B8)),
                  Text(
                    '${ticket.attachmentUrls.length}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                ],

                const Spacer(),

                // Assignee or Created By info
                if (ticket.assignedTo != null)
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 90),
                        child: Text(
                          ticket.assignedTo!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Unassigned',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                const SizedBox(width: 8),

                // Time ago
                Text(
                  _formatDate(ticket.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
