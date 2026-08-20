import 'package:flutter/material.dart';
import 'package:helpdesk/core/widgets/connectivity_checker_wrapper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
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
    final theme = Theme.of(context);

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
        .map((e) => ChartData(e.key.label, e.value, theme.colorScheme.primary))
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

    return ConnectivityCheckerWrapper(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Team Analytics & Workload',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
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
                      context: context,
                      title: 'Total Tickets',
                      value: '$totalTickets',
                      icon: Icons.confirmation_number_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      context: context,
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
                      context: context,
                      title: 'In Progress',
                      value: '$inProgressTickets',
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.statusInProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      context: context,
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
                      context: context,
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tickets by Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (categoryData.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text('No tickets data available.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                      )
                    else
                      SizedBox(
                        height: 240,
                        child: SfCircularChart(
                          legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            position: LegendPosition.bottom,
                            textStyle: TextStyle(color: theme.colorScheme.onSurface),
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                        ),
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Workload per Agent',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Icon(Icons.people_alt_outlined, color: theme.colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (agentWorkload.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('No active assignments currently.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                      )
                    else
                      ...agentWorkload.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  entry.key.isNotEmpty ? entry.key[0].toUpperCase() : 'A',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entry.value} active',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
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
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
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
