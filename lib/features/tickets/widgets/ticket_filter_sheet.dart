import 'package:flutter/material.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedPriority = null;
                        _assignedToMe = false;
                      });
                    },
                    child: Text(
                      'Reset All',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),

              // Staff Filter: Assigned to me switch
              if (isStaff) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Only Assigned to Me', style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    'Show requests currently owned by you',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  value: _assignedToMe,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _assignedToMe = val);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Priority Filter
              Text(
                'Priority',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
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
                    selectedColor: priority.color.withValues(alpha: 0.15),
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isSelected ? priority.color : AppColors.textPrimary,
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
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                    label: Text(cat.label),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
