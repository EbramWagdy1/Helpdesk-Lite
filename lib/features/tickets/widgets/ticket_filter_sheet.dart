import 'package:flutter/material.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/widgets/custom_button.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
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
  late bool _assignedToMe;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.cubit.selectedCategory;
    _selectedPriority = widget.cubit.selectedPriority;
    _assignedToMe = widget.cubit.showOnlyAssignedToMe;
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = widget.currentUser.role != UserRole.employee;
    final theme = Theme.of(context);

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
                    'Filter Tickets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedPriority = null;
                        _assignedToMe = false;
                      });
                    },
                    child: const Text(
                      'Reset All',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
                    ),
                  ),
                ],
              ),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 12),

              // Staff Filter: Assigned to me switch
              if (isStaff) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Only Assigned to Me', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  subtitle: Text(
                    'Show requests currently owned by you',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  value: _assignedToMe,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _assignedToMe = val);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Priority Filter
              Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(priority.label),
                    selected: isSelected,
                    selectedColor: priority.color.withValues(alpha: 0.2),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected ? priority.color : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                'Department / Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    label: Text(cat.label),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                text: 'Apply Filters',
                onPressed: () {
                  widget.cubit.filterByCategory(_selectedCategory);
                  widget.cubit.filterByPriority(_selectedPriority);
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
