import 'package:flutter/material.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

class TicketStatsCard extends StatelessWidget {
  final List<TicketModel> tickets;
  final TicketStatus? selectedStatus;
  final Function(TicketStatus?) onStatusSelected;

  const TicketStatsCard({
    super.key,
    required this.tickets,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = tickets.length;
    final openCount = tickets.where((t) => t.status == TicketStatus.open).length;
    final inProgressCount = tickets.where((t) => t.status == TicketStatus.inProgress).length;
    final resolvedCount = tickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatPill(
            context: context,
            label: context.l10n.all,
            count: totalCount,
            color: AppColors.primary,
            bgColor: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08),
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            context: context,
            label: context.l10n.open,
            count: openCount,
            color: AppColors.statusOpen,
            bgColor: isDark ? AppColors.statusOpen.withValues(alpha: 0.15) : AppColors.statusOpenBg,
            isSelected: selectedStatus == TicketStatus.open,
            onTap: () => onStatusSelected(TicketStatus.open),
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            context: context,
            label: context.l10n.inProgress,
            count: inProgressCount,
            color: AppColors.statusInProgress,
            bgColor: isDark ? AppColors.statusInProgress.withValues(alpha: 0.15) : AppColors.statusInProgressBg,
            isSelected: selectedStatus == TicketStatus.inProgress,
            onTap: () => onStatusSelected(TicketStatus.inProgress),
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            context: context,
            label: context.l10n.resolved,
            count: resolvedCount,
            color: AppColors.statusResolved,
            bgColor: isDark ? AppColors.statusResolved.withValues(alpha: 0.15) : AppColors.statusResolvedBg,
            isSelected: selectedStatus == TicketStatus.resolved,
            onTap: () => onStatusSelected(TicketStatus.resolved),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
