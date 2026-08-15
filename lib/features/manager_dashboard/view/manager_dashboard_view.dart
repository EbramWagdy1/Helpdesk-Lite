import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

class ChartData {
  final String category;
  final int count;
  final Color color;

  ChartData(this.category, this.count, this.color);
}

class ManagerDashboardView extends StatelessWidget {
  final List<TicketModel> allTickets;
  final UserModel currentUser;

  const ManagerDashboardView({
    super.key,
    required this.allTickets,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    // KPI Calculations
    final totalTickets = allTickets.length;
    final openTickets = allTickets.where((t) => t.status == TicketStatus.open).length;
    final inProgressTickets = allTickets.where((t) => t.status == TicketStatus.inProgress).length;
    final resolvedTickets = allTickets.where((t) => t.status == TicketStatus.resolved).length;
    final unassignedTickets = allTickets.where((t) => t.assignedTo == null && t.status != TicketStatus.closed).length;

    // Data for Category Chart
    final Map<TicketCategory, int> categoryCounts = {};
    for (var cat in TicketCategory.values) {
      categoryCounts[cat] = allTickets.where((t) => t.category == cat).length;
    }
    final categoryData = categoryCounts.entries
        .where((e) => e.value > 0)
        .map((e) => ChartData(e.key.label, e.value, AppColors.primary))
        .toList();

    // Data for Priority Chart
    final Map<TicketPriority, int> priorityCounts = {};
    for (var p in TicketPriority.values) {
      priorityCounts[p] = allTickets.where((t) => t.priority == p).length;
    }
    final priorityData = priorityCounts.entries
        .map((e) => ChartData(e.key.label, e.value, e.key.color))
        .toList();

    // Agent Workload Map
    final Map<String, int> agentWorkload = {};
    for (var ticket in allTickets) {
      if (ticket.assignedTo != null && ticket.status != TicketStatus.closed) {
        final name = ticket.assignedTo!.name;
        agentWorkload[name] = (agentWorkload[name] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Team Analytics & Workload', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Tickets',
                    value: '$totalTickets',
                    icon: Icons.confirmation_number_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Open / New',
                    value: '$openTickets',
                    icon: Icons.mark_email_unread_outlined,
                    color: AppColors.statusOpen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'In Progress',
                    value: '$inProgressTickets',
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.statusInProgress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Resolved',
                    value: '$resolvedTickets',
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusResolved,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Unassigned',
                    value: '$unassignedTickets',
                    icon: Icons.person_search_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category Breakdown Chart (Doughnut Chart)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tickets by Category',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (categoryData.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No tickets data available.')),
                    )
                  else
                    SizedBox(
                      height: 240,
                      child: SfCircularChart(
                        legend: const Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          position: LegendPosition.bottom,
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<ChartData, String>(
                            dataSource: categoryData,
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.count,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                            innerRadius: '60%',
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Priority Distribution Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority Distribution',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      series: <CartesianSeries>[
                        ColumnSeries<ChartData, String>(
                          dataSource: priorityData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.count,
                          pointColorMapper: (ChartData data, _) => data.color,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Agent Workload Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Workload per Agent',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (agentWorkload.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No active assignments currently.')),
                    )
                  else
                    ...agentWorkload.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                entry.key.isNotEmpty ? entry.key[0].toUpperCase() : 'A',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value} active',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
