import 'package:flutter/material.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
import 'package:helpdesk/core/widgets/custom_button.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/services/sla_service.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_cubit.dart';

class TicketFilterSheet extends StatefulWidget {
  final TicketListCubit cubit;
  final UserModel currentUser;

  const TicketFilterSheet({
    super.key,
    required this.cubit,
    required this.currentUser,
  });

  @override
  State<TicketFilterSheet> createState() => _TicketFilterSheetState();
}

class _TicketFilterSheetState extends State<TicketFilterSheet> {
  late TicketCategory? _selectedCategory;
  late TicketPriority? _selectedPriority;
  late SlaStatus? _selectedSlaStatus;
  late bool _assignedToMe;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.cubit.selectedCategory;
    _selectedPriority = widget.cubit.selectedPriority;
    _selectedSlaStatus = widget.cubit.selectedSlaStatus;
    _assignedToMe = widget.cubit.showOnlyAssignedToMe;
  }

  String _getSlaLabel(BuildContext context, SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return context.l10n.slaOnTrack;
      case SlaStatus.warning:
        return context.l10n.slaAtRisk;
      case SlaStatus.breached:
        return context.l10n.slaBreached;
      case SlaStatus.achieved:
        return context.l10n.slaAchieved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = widget.currentUser.role != UserRole.employee;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.filterTickets,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedPriority = null;
                        _selectedSlaStatus = null;
                        _assignedToMe = false;
                      });
                    },
                    child: Text(
                      context.l10n.resetAll,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 12),

              // Staff Filter: Assigned to me switch
              if (isStaff) ...[
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.assignedToMe, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  subtitle: Text(
                    context.l10n.showOnlyOwnedRequests,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                  ),
                  value: _assignedToMe,
                  activeTrackColor: theme.colorScheme.primary,
                  activeThumbColor: Colors.white,
                  inactiveThumbColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  onChanged: (val) {
                    setState(() => _assignedToMe = val);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // SLA Status Filter (Active tickets)
              Text(
                context.l10n.sla,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SlaStatus.onTrack,
                  SlaStatus.warning,
                  SlaStatus.breached,
                ].map((status) {
                  final isSelected = _selectedSlaStatus == status;
                  return ChoiceChip(
                    label: Text(_getSlaLabel(context, status)),
                    selected: isSelected,
                    selectedColor: isDark ? status.color.withValues(alpha: 0.25) : status.color.withValues(alpha: 0.15),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isSelected
                          ? status.color
                          : (isDark ? const Color(0xFF334155) : theme.colorScheme.outline.withValues(alpha: 0.5)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? status.color : (isDark ? const Color(0xFFF1F5F9) : theme.colorScheme.onSurface),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSlaStatus = selected ? status : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority Filter
              Text(
                context.l10n.priority,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(priority.getLocalizedLabel(context)),
                    selected: isSelected,
                    selectedColor: isDark ? priority.color.withValues(alpha: 0.25) : priority.color.withValues(alpha: 0.15),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isSelected
                          ? priority.color
                          : (isDark ? const Color(0xFF334155) : theme.colorScheme.outline.withValues(alpha: 0.5)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? priority.color : (isDark ? const Color(0xFFF1F5F9) : theme.colorScheme.onSurface),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = selected ? priority : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Category Filter
              Text(
                context.l10n.department,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? theme.colorScheme.primary : (isDark ? const Color(0xFF94A3B8) : theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    label: Text(cat.getLocalizedLabel(context)),
                    selected: isSelected,
                    selectedColor: isDark ? theme.colorScheme.primary.withValues(alpha: 0.25) : theme.colorScheme.primary.withValues(alpha: 0.15),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? const Color(0xFF334155) : theme.colorScheme.outline.withValues(alpha: 0.5)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : (isDark ? const Color(0xFFF1F5F9) : theme.colorScheme.onSurface),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Apply Filters Button
              CustomButton(
                text: context.l10n.filterTickets,
                onPressed: () {
                  widget.cubit.filterByCategory(_selectedCategory);
                  widget.cubit.filterByPriority(_selectedPriority);
                  widget.cubit.filterBySlaStatus(_selectedSlaStatus);
                  if (isStaff) {
                    widget.cubit.toggleAssignedToMe(_assignedToMe, widget.currentUser.uid);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
