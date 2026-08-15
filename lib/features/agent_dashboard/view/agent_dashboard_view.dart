import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';
import 'package:helpdesk/core/widgets/verified_badge_widget.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/profile/view/profile_view.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view/ticket_details_view.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_cubit.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_state.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_card_widget.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_filter_sheet.dart';

enum AgentQueueTab {
  departmentQueue,
  assignedToMe,
  urgentQueue,
}

class AgentDashboardView extends StatefulWidget {
  final UserModel currentUser;

  const AgentDashboardView({
    super.key,
    required this.currentUser,
  });

  @override
  State<AgentDashboardView> createState() => _AgentDashboardViewState();
}

class _AgentDashboardViewState extends State<AgentDashboardView> {
  AgentQueueTab _selectedTab = AgentQueueTab.departmentQueue;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTextStyles.titleMedium),
        content: const Text('Are you sure you want to sign out from the Agent Hub?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authCubit.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketListCubit()..initializeTicketStream(currentUser: widget.currentUser),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<TicketListCubit, TicketListState>(
            builder: (context, state) {
              final ticketCubit = TicketListCubit.get(context);

              List<TicketModel> allDepartmentTickets = [];
              List<TicketModel> filteredTickets = [];

              if (state is TicketListLoadedState) {
                allDepartmentTickets = state.allTickets;
                filteredTickets = state.filteredTickets;
              }

              // Filter based on active tab
              List<TicketModel> displayedTickets;
              switch (_selectedTab) {
                case AgentQueueTab.departmentQueue:
                  displayedTickets = filteredTickets;
                  break;
                case AgentQueueTab.assignedToMe:
                  displayedTickets = filteredTickets.where((t) => t.assignedTo?.uid == widget.currentUser.uid).toList();
                  break;
                case AgentQueueTab.urgentQueue:
                  displayedTickets = filteredTickets.where((t) => t.priority == TicketPriority.high || t.priority == TicketPriority.urgent).toList();
                  break;
              }

              final deptQueueCount = allDepartmentTickets.length;
              final assignedCount = allDepartmentTickets.where((t) => t.assignedTo?.uid == widget.currentUser.uid).length;
              final urgentCount = allDepartmentTickets.where((t) => (t.priority == TicketPriority.high || t.priority == TicketPriority.urgent) && t.status != TicketStatus.closed).length;
              final resolvedCount = allDepartmentTickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).length;

              return CustomScrollView(
                slivers: [
                  // Top Agent Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          // Interactive Profile Avatar
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileView(user: widget.currentUser),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                              child: Text(
                                widget.currentUser.name.isNotEmpty ? widget.currentUser.name[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileView(user: widget.currentUser),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.currentUser.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.currentUser.isVerified) ...[
                                        const SizedBox(width: 4),
                                        const VerifiedBadgeWidget(size: 14),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${widget.currentUser.department} Agent',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'On-Duty',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary),
                            tooltip: 'Account Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileView(user: widget.currentUser),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
                            tooltip: 'Filter Queue',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (_) => TicketFilterSheet(
                                  cubit: ticketCubit,
                                  currentUser: widget.currentUser,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                            tooltip: 'Sign Out',
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Agent Metrics Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Dept Queue',
                              value: '$deptQueueCount',
                              icon: Icons.all_inbox_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Assigned to Me',
                              value: '$assignedCount',
                              icon: Icons.assignment_ind_rounded,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Urgent',
                              value: '$urgentCount',
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.priorityHigh,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Resolved',
                              value: '$resolvedCount',
                              icon: Icons.task_alt_rounded,
                              color: AppColors.statusResolved,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => ticketCubit.search(val),
                          decoration: InputDecoration(
                            hintText: 'Search department tickets, ID, requester...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      ticketCubit.search('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Queue Navigation Tabs (Segmented)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQueueTabItem(
                                label: 'Dept Queue ($deptQueueCount)',
                                tab: AgentQueueTab.departmentQueue,
                              ),
                            ),
                            Expanded(
                              child: _buildQueueTabItem(
                                label: 'My Assigned ($assignedCount)',
                                tab: AgentQueueTab.assignedToMe,
                              ),
                            ),
                            Expanded(
                              child: _buildQueueTabItem(
                                label: 'Urgent ($urgentCount)',
                                tab: AgentQueueTab.urgentQueue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Ticket List
                  if (state is TicketListLoadingState)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (displayedTickets.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.done_all_rounded, size: 48, color: AppColors.success),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedTab == AgentQueueTab.assignedToMe
                                    ? 'No tickets assigned to you right now'
                                    : 'Queue is clean!',
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selectedTab == AgentQueueTab.assignedToMe
                                    ? 'Check the "Dept Queue" tab to claim incoming support tickets.'
                                    : 'All tickets for your department have been handled or assigned.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final ticket = displayedTickets[index];
                            return TicketCardWidget(
                              ticket: ticket,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketDetailsView(
                                      ticketId: ticket.id,
                                      currentUser: widget.currentUser,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: displayedTickets.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQueueTabItem({
    required String label,
    required AgentQueueTab tab,
  }) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
