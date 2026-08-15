import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';
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
    return BlocProvider(
      create: (context) => TicketListCubit()..initializeTicketStream(currentUser: widget.currentUser),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: NavigationBar(
            selectedIndex: _selectedViewIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedViewIndex = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFEFF6FF),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded, color: Color(0xFF2563EB)),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF2563EB)),
                label: 'Tickets',
              ),
              NavigationDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge_rounded, color: Color(0xFF2563EB)),
                label: 'Support Team',
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
                              backgroundColor: const Color(0xFF0F172A),
                              child: Text(
                                widget.currentUser.name.isNotEmpty ? widget.currentUser.name[0].toUpperCase() : 'M',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
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
                                  const Text(
                                    'Operations Manager • Executive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
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
                            icon: const Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 22),
                            tooltip: 'Create Ticket',
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
                            icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF334155), size: 20),
                            tooltip: 'Profile',
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
    );
  }

  // -------------------------------------------------------------
  // TAB 1: EXECUTIVE ANALYTICS & KPIS
  // -------------------------------------------------------------
  Widget _buildAnalyticsTab(BuildContext context, List<TicketModel> allTickets, bool isLoading) {
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
        .map((e) => _ChartItem(e.key.label, e.value, AppColors.primary))
        .toList();

    // Priority Distribution Data
    final Map<TicketPriority, int> priorityCounts = {};
    for (var p in TicketPriority.values) {
      priorityCounts[p] = allTickets.where((t) => t.priority == p).length;
    }
    final priorityData = priorityCounts.entries
        .where((e) => e.value > 0)
        .map((e) => _ChartItem(e.key.label, e.value, e.key.color))
        .toList();

    // Agent Workload Map
    final Map<String, int> agentWorkload = {};
    for (var ticket in allTickets) {
      if (ticket.assignedTo != null && ticket.status != TicketStatus.closed) {
        final name = ticket.assignedTo!.name;
        agentWorkload[name] = (agentWorkload[name] ?? 0) + 1;
      }
    }

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
                  title: 'Total Tickets',
                  value: '$total',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Resolution Rate',
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
                  title: 'Open / Pending',
                  value: '$open',
                  icon: Icons.mark_email_unread_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'In Progress',
                  value: '$inProgress',
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Unassigned',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tickets by Department',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  categoryData.isEmpty
                      ? const SizedBox(
                          height: 150,
                          child: Center(child: Text('No ticket data yet')),
                        )
                      : SizedBox(
                          height: 200,
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(
                              labelStyle: TextStyle(fontSize: 10),
                            ),
                            primaryYAxis: const NumericAxis(
                              interval: 2,
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<_ChartItem, String>(
                                dataSource: categoryData,
                                xValueMapper: (_ChartItem data, _) => data.label,
                                yValueMapper: (_ChartItem data, _) => data.value,
                                color: AppColors.primary,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
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
                        'Priority Distribution',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  priorityData.isEmpty
                      ? const SizedBox(
                          height: 150,
                          child: Center(child: Text('No ticket data yet')),
                        )
                      : SizedBox(
                          height: 220,
                          child: SfCircularChart(
                            legend: const Legend(
                              isVisible: true,
                              position: LegendPosition.right,
                              overflowMode: LegendItemOverflowMode.wrap,
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
                  decoration: InputDecoration(
                    hintText: 'Search tickets across company...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF0F172A)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
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
                          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text(
                            'No tickets match your filters',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => cubit.resetFilters(),
                            child: const Text('Reset Filters'),
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
  // TAB 3: AGENTS SUPPORT & VERIFICATION MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildAgentsManagementTab(BuildContext context, List<TicketModel> allTickets) {
    return StreamBuilder<List<UserModel>>(
      stream: AuthRepository().streamSupportAgents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)));
        }

        final agents = snapshot.data ?? [];
        final verifiedCount = agents.where((a) => a.isVerified).length;
        final pendingCount = agents.length - verifiedCount;

        // Filter agents by search and selected status
        final query = _agentSearchController.text.toLowerCase().trim();
        final filteredAgents = agents.where((agent) {
          final matchesSearch = query.isEmpty ||
              agent.name.toLowerCase().contains(query) ||
              agent.email.toLowerCase().contains(query) ||
              agent.department.toLowerCase().contains(query);

          if (!matchesSearch) return false;

          if (_agentFilter == 'verified') return agent.isVerified;
          if (_agentFilter == 'pending') return !agent.isVerified;
          return true;
        }).toList();

        return Column(
          children: [
            // Top Summary Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Agents', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          '${agents.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Verified', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '$verifiedCount',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                              ),
                              const SizedBox(width: 4),
                              const VerifiedBadgeWidget(size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Text(
                            '$pendingCount',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search and Status Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _agentSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search support specialists...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildAgentFilterChip('all', 'All (${agents.length})'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip('verified', 'Verified ($verifiedCount)'),
                  const SizedBox(width: 8),
                  _buildAgentFilterChip('pending', 'Pending ($pendingCount)'),
                ],
              ),
            ),

            // Agents List
            Expanded(
              child: filteredAgents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text(
                            'No support agents found',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filteredAgents.length,
                      itemBuilder: (context, index) {
                        final agent = filteredAgents[index];
                        final activeTicketsCount = allTickets
                            .where((t) => t.assignedTo?.uid == agent.uid && t.status != TicketStatus.closed)
                            .length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: agent.isVerified ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                              width: agent.isVerified ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: agent.isVerified
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFF1F5F9),
                                    child: Text(
                                      agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: agent.isVerified ? const Color(0xFF2563EB) : const Color(0xFF475569),
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
                                                agent.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (agent.isVerified) ...[
                                              const SizedBox(width: 5),
                                              const VerifiedBadgeWidget(size: 15),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${agent.department} • ${agent.email}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Verification Toggle
                                  Switch.adaptive(
                                    value: agent.isVerified,
                                    activeTrackColor: const Color(0xFF2563EB),
                                    activeThumbColor: Colors.white,
                                    onChanged: (newValue) async {
                                      try {
                                        await AuthRepository().updateAgentVerification(
                                          agentUid: agent.uid,
                                          isVerified: newValue,
                                        );
                                        if (context.mounted) {
                                          CustomSnackBar.showSuccess(
                                            context,
                                            message: newValue
                                                ? '${agent.name} is now a Verified Agent ✓'
                                                : '${agent.name} verification revoked.',
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
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      '$activeTicketsCount Active Tickets',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  if (agent.isVerified)
                                    const VerifiedBadgeWidget(showLabel: true, label: 'Verified Specialist')
                                  else
                                    const Text(
                                      'Pending Verification',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
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

  Widget _buildAgentFilterChip(String key, String label) {
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
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                style: AppTextStyles.titleLarge.copyWith(
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
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
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
