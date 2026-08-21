import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/widgets/connectivity_checker_wrapper.dart';
import 'package:helpdesk/core/widgets/custom_snackbar.dart';
import 'package:helpdesk/core/widgets/verified_badge_widget.dart';
import 'package:helpdesk/features/auth/data/auth_repository.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/profile/view/profile_view.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view/create_ticket_view.dart';
import 'package:helpdesk/features/tickets/view/ticket_details_view.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_cubit.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_list_state.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_card_widget.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_filter_sheet.dart';

class ManagerExecutiveView extends StatefulWidget {
  final UserModel currentUser;

  const ManagerExecutiveView({
    super.key,
    required this.currentUser,
  });

  @override
  State<ManagerExecutiveView> createState() => _ManagerExecutiveViewState();
}

class _ManagerExecutiveViewState extends State<ManagerExecutiveView> {
  int _selectedViewIndex = 0; // 0: Analytics, 1: Tickets, 2: Agents
  final _searchController = TextEditingController();
  final _agentSearchController = TextEditingController();
  String _agentFilter = 'all'; // 'all', 'verified', 'pending'

  @override
  void dispose() {
    _searchController.dispose();
    _agentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConnectivityCheckerWrapper(
      child: BlocProvider(
        create: (context) => TicketListCubit()..initializeTicketStream(currentUser: widget.currentUser),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4))),
            ),
            child: NavigationBar(
              selectedIndex: _selectedViewIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedViewIndex = index;
                });
              },
              backgroundColor: theme.cardColor,
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  selectedIcon: Icon(Icons.insights_rounded, color: theme.colorScheme.primary),
                  label: context.l10n.analytics,
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: theme.colorScheme.primary),
                  label: context.l10n.tickets,
                ),
                NavigationDestination(
                  icon: Icon(Icons.badge_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  selectedIcon: Icon(Icons.badge_rounded, color: theme.colorScheme.primary),
                  label: context.l10n.supportTeam,
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<TicketListCubit, TicketListState>(
              builder: (context, state) {
                final ticketCubit = TicketListCubit.get(context);

                List<TicketModel> allTickets = [];
                List<TicketModel> filteredTickets = [];

                if (state is TicketListLoadedState) {
                  allTickets = state.allTickets;
                  filteredTickets = state.filteredTickets;
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Column(
                    children: [
                      // Executive Top Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4))),
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
                                radius: 20,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  widget.currentUser.name.isNotEmpty ? widget.currentUser.name[0].toUpperCase() : 'M',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.currentUser.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const VerifiedBadgeWidget(size: 14),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.currentUser.role == UserRole.manager
                                          ? context.l10n.operationsManagerExecutive
                                          : widget.currentUser.role.getLocalizedLabel(context),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary, size: 22),
                              tooltip: context.l10n.newTicket,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateTicketView(currentUser: widget.currentUser),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onSurface, size: 20),
                              tooltip: context.l10n.profile,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileView(user: widget.currentUser),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Main View Content
                      Expanded(
                        child: _selectedViewIndex == 0
                            ? _buildAnalyticsTab(context, allTickets, state is TicketListLoadingState)
                            : _selectedViewIndex == 1
                                ? _buildTicketsSupervisionTab(context, ticketCubit, state, allTickets, filteredTickets)
                                : _buildAgentsManagementTab(context, allTickets),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: EXECUTIVE ANALYTICS & KPIS
  // -------------------------------------------------------------
  Widget _buildAnalyticsTab(BuildContext context, List<TicketModel> allTickets, bool isLoading) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = allTickets.length;
    final open = allTickets.where((t) => t.status == TicketStatus.open).length;
    final inProgress = allTickets.where((t) => t.status == TicketStatus.inProgress).length;
    final resolved = allTickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).length;
    final unassigned = allTickets.where((t) => t.assignedTo == null && t.status != TicketStatus.closed).length;

    final resolutionRate = total > 0 ? ((resolved / total) * 100).toStringAsFixed(1) : '0';

    // Category Distribution Data
    final Map<TicketCategory, int> categoryCounts = {};
    for (var cat in TicketCategory.values) {
      categoryCounts[cat] = allTickets.where((t) => t.category == cat).length;
    }
    final categoryData = categoryCounts.entries
        .where((e) => e.value > 0)
        .map((e) => _ChartItem(e.key.getLocalizedLabel(context), e.value, theme.colorScheme.primary))
        .toList();

    // Priority Distribution Data
    final Map<TicketPriority, int> priorityCounts = {};
    for (var p in TicketPriority.values) {
      priorityCounts[p] = allTickets.where((t) => t.priority == p).length;
    }
    final priorityData = priorityCounts.entries
        .where((e) => e.value > 0)
        .map((e) => _ChartItem(e.key.getLocalizedLabel(context), e.value, e.key.color))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  title: context.l10n.totalTickets,
                  value: '$total',
                  icon: Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  title: context.l10n.resolutionRate,
                  value: '$resolutionRate%',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  title: context.l10n.openPending,
                  value: '$open',
                  icon: Icons.mark_email_unread_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  title: context.l10n.inProgress,
                  value: '$inProgress',
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  title: context.l10n.unassigned,
                  value: '$unassigned',
                  icon: Icons.person_off_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Department Volume Breakdown Chart
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.ticketsByDepartment,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  categoryData.isEmpty
                      ? SizedBox(
                          height: 150,
                          child: Center(child: Text(context.l10n.noSupportTicketsYet, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                        )
                      : SizedBox(
                          height: 200,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              labelStyle: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface),
                            ),
                            primaryYAxis: NumericAxis(
                              interval: 2,
                              labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<_ChartItem, String>(
                                dataSource: categoryData,
                                xValueMapper: (_ChartItem data, _) => data.label,
                                yValueMapper: (_ChartItem data, _) => data.value,
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Priority Distribution Doughnut Chart
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart_outline_rounded, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.priorityDistribution,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  priorityData.isEmpty
                      ? SizedBox(
                          height: 150,
                          child: Center(child: Text(context.l10n.noSupportTicketsYet, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                        )
                      : SizedBox(
                          height: 220,
                          child: SfCircularChart(
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.right,
                              overflowMode: LegendItemOverflowMode.wrap,
                              textStyle: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                            series: <CircularSeries>[
                              DoughnutSeries<_ChartItem, String>(
                                dataSource: priorityData,
                                xValueMapper: (_ChartItem data, _) => data.label,
                                yValueMapper: (_ChartItem data, _) => data.value,
                                pointColorMapper: (_ChartItem data, _) => data.color,
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                                innerRadius: '60%',
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: TICKETS SUPERVISION
  // -------------------------------------------------------------
  Widget _buildTicketsSupervisionTab(
    BuildContext context,
    TicketListCubit cubit,
    TicketListState state,
    List<TicketModel> allTickets,
    List<TicketModel> filteredTickets,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search & Filter Action Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => cubit.search(val),
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchDepartmentTicketsHint,
                    hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list_rounded, color: theme.colorScheme.onSurface),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: theme.cardColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => TicketFilterSheet(
                        cubit: cubit,
                        currentUser: widget.currentUser,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Ticket List Content
        Expanded(
          child: state is TicketListLoadingState
              ? const Center(child: CircularProgressIndicator())
              : filteredTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.noMatchingTickets,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => cubit.resetFilters(),
                            child: Text(context.l10n.resetFilters),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = filteredTickets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TicketCardWidget(
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
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: TEAM & USER ROLE MANAGEMENT (PROMOTION & VERIFICATION)
  // -------------------------------------------------------------
  Widget _buildAgentsManagementTab(BuildContext context, List<TicketModel> allTickets) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<UserModel>>(
      stream: AuthRepository().streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
        }

        final users = snapshot.data ?? [];
        final agents = users.where((u) => u.role == UserRole.agent).toList();
        final employees = users.where((u) => u.role == UserRole.employee).toList();
        final verifiedAgentsCount = agents.where((a) => a.isVerified).length;
        final pendingAgentsCount = agents.length - verifiedAgentsCount;

        // Filter users by search and selected category
        final query = _agentSearchController.text.toLowerCase().trim();
        final filteredUsers = users.where((user) {
          final matchesSearch = query.isEmpty ||
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.department.toLowerCase().contains(query) ||
              user.role.name.toLowerCase().contains(query);

          if (!matchesSearch) return false;

          if (_agentFilter == 'agents') return user.role == UserRole.agent;
          if (_agentFilter == 'employees') return user.role == UserRole.employee;
          if (_agentFilter == 'verified') return user.role == UserRole.agent && user.isVerified;
          if (_agentFilter == 'pending') return user.role == UserRole.agent && !user.isVerified;
          return true;
        }).toList();

        return Column(
          children: [
            // Top Summary Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.allUsers, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
                        const SizedBox(height: 2),
                        Text(
                          '${users.length}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: theme.dividerColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.agents, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${agents.length}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 4),
                              const VerifiedBadgeWidget(size: 13),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: theme.dividerColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.employees, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
                          const SizedBox(height: 2),
                          Text(
                            '${employees.length}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _agentSearchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: context.l10n.searchAgentsHint,
                  hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildAgentFilterChip(context, 'all', '${context.l10n.all} (${users.length})'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip(context, 'agents', '${context.l10n.agents} (${agents.length})'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip(context, 'employees', '${context.l10n.employees} (${employees.length})'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip(context, 'verified', '${context.l10n.verified} ($verifiedAgentsCount)'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip(context, 'pending', '${context.l10n.pending} ($pendingAgentsCount)'),
                ],
              ),
            ),

            // Users List
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.noAgentsFound,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isAgent = user.role == UserRole.agent;
                        final isEmployee = user.role == UserRole.employee;
                        final isManager = user.role == UserRole.manager;

                        final activeTicketsCount = isAgent
                            ? allTickets
                                .where((t) => t.assignedTo?.uid == user.uid && t.status != TicketStatus.closed)
                                .length
                            : 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAgent && user.isVerified
                                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                  : (isManager
                                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                                      : theme.colorScheme.outline.withValues(alpha: 0.5)),
                              width: isAgent && user.isVerified ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isAgent
                                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                        : (isManager
                                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                    child: Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isAgent
                                            ? theme.colorScheme.primary
                                            : (isManager
                                                ? const Color(0xFF8B5CF6)
                                                : theme.colorScheme.onSurface),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.name,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isAgent && user.isVerified) ...[
                                              const SizedBox(width: 5),
                                              const VerifiedBadgeWidget(size: 15),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${context.getLocalizedDepartment(user.department)} • ${user.email}',
                                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Agent Verification Toggle OR Role Menu
                                  if (isAgent)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.isVerified ? context.l10n.verified : context.l10n.pending,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: user.isVerified
                                                ? (isDark ? const Color(0xFF60A5FA) : theme.colorScheme.primary)
                                                : const Color(0xFFF59E0B),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Switch.adaptive(
                                          value: user.isVerified,
                                          activeTrackColor: theme.colorScheme.primary,
                                          activeThumbColor: Colors.white,
                                          inactiveThumbColor: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                                          inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                          trackOutlineColor: WidgetStateProperty.all(isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                                          onChanged: (newValue) async {
                                            try {
                                              await AuthRepository().updateAgentVerification(
                                                agentUid: user.uid,
                                                isVerified: newValue,
                                              );
                                              if (context.mounted) {
                                                CustomSnackBar.showSuccess(
                                                  context,
                                                  message: newValue
                                                      ? '${user.name} is now a Verified Agent ✓'
                                                      : '${user.name} verification revoked.',
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                CustomSnackBar.showError(
                                                  context,
                                                  message: e.toString().replaceAll('Exception: ', ''),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(
                                        Icons.manage_accounts_rounded,
                                        color: isDark ? const Color(0xFF38BDF8) : theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                      tooltip: context.l10n.manageUserRole,
                                      onPressed: () => _showRoleManagementDialog(context, user),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(height: 1, color: theme.dividerColor),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Role Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAgent
                                          ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : theme.colorScheme.primary.withValues(alpha: 0.12))
                                          : (isManager
                                              ? (isDark ? const Color(0xFF5B21B6).withValues(alpha: 0.4) : const Color(0xFF8B5CF6).withValues(alpha: 0.12))
                                              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isAgent
                                            ? (isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.3))
                                            : (isManager
                                                ? (isDark ? const Color(0xFFA78BFA).withValues(alpha: 0.5) : const Color(0xFF8B5CF6).withValues(alpha: 0.3))
                                                : (isDark ? const Color(0xFF475569) : theme.colorScheme.outline.withValues(alpha: 0.3))),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isAgent
                                              ? Icons.support_agent_rounded
                                              : (isManager ? Icons.security_rounded : Icons.person_outline_rounded),
                                          size: 13,
                                          color: isAgent
                                              ? (isDark ? const Color(0xFF60A5FA) : theme.colorScheme.primary)
                                              : (isManager
                                                  ? const Color(0xFFA78BFA)
                                                  : (isDark ? const Color(0xFFCBD5E1) : theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.role.getLocalizedLabel(context),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isAgent
                                                ? (isDark ? const Color(0xFF93C5FD) : theme.colorScheme.primary)
                                                : (isManager
                                                    ? (isDark ? const Color(0xFFDDD6FE) : const Color(0xFF8B5CF6))
                                                    : (isDark ? const Color(0xFFF1F5F9) : theme.colorScheme.onSurface)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quick Action button for Employees & Agents
                                  if (isEmployee)
                                    TextButton.icon(
                                      onPressed: () => _showRoleManagementDialog(context, user),
                                      icon: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 16,
                                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                      ),
                                      label: Text(
                                        context.l10n.promoteToAgent,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        backgroundColor: isDark
                                            ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                                            : const Color(0xFF0284C7).withValues(alpha: 0.1),
                                        side: isDark
                                            ? BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.2)
                                            : null,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    )
                                  else if (isAgent)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            '$activeTicketsCount ${context.l10n.activeTickets}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                          tooltip: context.l10n.changeRole,
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _showRoleManagementDialog(context, user),
                                        ),
                                      ],
                                    )
                                  else
                                    const SizedBox.shrink(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showRoleManagementDialog(BuildContext context, UserModel targetUser) {
    final theme = Theme.of(context);
    final departments = [
      'IT & Systems',
      'Human Resources',
      'Facilities & Office',
      'Operations',
      'Finance & Payroll',
      'Other Support',
    ];

    UserRole selectedRole = targetUser.role == UserRole.employee ? UserRole.agent : targetUser.role;
    String selectedDepartment = targetUser.department;
    bool isVerified = targetUser.role == UserRole.employee ? true : targetUser.isVerified;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.manageUserRole,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  Text(
                    '${targetUser.name} (${targetUser.email})',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 12),

                  // Role Selection
                  Text(
                    context.l10n.workspaceRole,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: UserRole.values.map((role) {
                      final isSelected = selectedRole == role;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedRole = role;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              role.getLocalizedLabel(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Department Selection
                  Text(
                    context.l10n.department,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: departments.contains(selectedDepartment) ? selectedDepartment : departments.first,
                        dropdownColor: theme.cardColor,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                        items: departments.map((dept) {
                          return DropdownMenuItem<String>(
                            value: dept,
                            child: Text(
                              context.getLocalizedDepartment(dept),
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedDepartment = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verification Switch (for Agents)
                  if (selectedRole == UserRole.agent) ...[
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        context.l10n.verifiedSpecialist,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        context.l10n.verified,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      value: isVerified,
                      activeTrackColor: theme.colorScheme.primary,
                      activeThumbColor: Colors.white,
                      onChanged: (val) {
                        setModalState(() {
                          isVerified = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 16),

                  // Save / Promote Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              try {
                                await AuthRepository().updateUserRole(
                                  uid: targetUser.uid,
                                  newRole: selectedRole,
                                  department: selectedDepartment,
                                  isVerified: selectedRole == UserRole.employee ? false : isVerified,
                                );
                                if (context.mounted) {
                                  Navigator.pop(modalContext);
                                  CustomSnackBar.showSuccess(
                                    context,
                                    message: context.l10n.roleUpdatedSuccess,
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (context.mounted) {
                                  CustomSnackBar.showError(
                                    context,
                                    message: e.toString().replaceAll('Exception: ', ''),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              context.l10n.saveChanges,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgentFilterChip(BuildContext context, String key, String label) {
    final theme = Theme.of(context);
    final isSelected = _agentFilter == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _agentFilter = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: color),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final int value;
  final Color color;

  _ChartItem(this.label, this.value, this.color);
}
