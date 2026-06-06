import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/admin_drawer.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(String route) onNavigate;
  final String currentRoute;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: AdminDrawer(
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dp, _) {
          if (dp.isLoading && dp.stats.totalUsers == 0) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dp.error != null && dp.stats.totalUsers == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off,
                        size: 48, color: AdminColors.textLow),
                    const SizedBox(height: 16),
                    Text(
                      dp.error!,
                      style: const TextStyle(color: AdminColors.textMedium),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => dp.fetchDashboard(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => dp.fetchDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(dp),
                  const SizedBox(height: 20),
                  _buildRevenueChart(dp),
                  const SizedBox(height: 20),
                  _buildSystemHealth(dp),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(DashboardProvider dp) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Users',
                value: _formatNumber(dp.stats.totalUsers),
                icon: Icons.group,
                color: AdminColors.primary,
                subtitle: '${_formatNumber(dp.stats.newUsersToday)} today',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Active Today',
                value: _formatNumber(dp.stats.activeToday),
                icon: Icons.trending_up,
                color: AdminColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Revenue (Month)',
                value: '\$${_formatAmount(dp.stats.revenueThisMonth)}',
                icon: Icons.attach_money,
                color: AdminColors.warning,
                subtitle: '\$${_formatAmount(dp.stats.revenueToday)} today',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Exports Today',
                value: _formatNumber(dp.stats.exportsToday),
                icon: Icons.file_upload,
                color: AdminColors.info,
                subtitle: '${_formatNumber(dp.stats.exportsThisMonth)} this month',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Active AI Jobs',
                value: _formatNumber(dp.stats.activeJobs),
                icon: Icons.auto_awesome,
                color: AdminColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Pending',
                value: _formatNumber(
                    dp.stats.pendingApprovals + dp.stats.openTickets),
                icon: Icons.checklist,
                color: AdminColors.warning,
                subtitle:
                    '${dp.stats.pendingApprovals} approvals, ${dp.stats.openTickets} tickets',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart(DashboardProvider dp) {
    final points = dp.chartData.revenueHistory;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = points.fold<double>(
        0, (max, p) => p.amount > max ? p.amount : max);
    final minY = points.fold<double>(
        double.infinity, (min, p) => p.amount < min ? p.amount : min);
    final adjustedMin = minY == double.infinity ? 0 : minY * 0.9;
    final adjustedMax = maxY == 0 ? 1000 : maxY * 1.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue (7 days)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (adjustedMax - adjustedMin) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AdminColors.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AdminColors.textLow,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            days[points[idx].date.weekday - 1],
                            style: const TextStyle(
                              fontSize: 9,
                              color: AdminColors.textLow,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: adjustedMin.toDouble(),
                maxY: adjustedMax.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: points.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.amount);
                    }).toList(),
                    isCurved: true,
                    color: AdminColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AdminColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        '\$${spot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: AdminColors.textHigh,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth(DashboardProvider dp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Health',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 16),
          _healthRow(
            'Server Uptime',
            '${dp.stats.serverUptime.toStringAsFixed(1)}%',
            dp.stats.serverUptime > 99
                ? AdminColors.success
                : AdminColors.warning,
          ),
          const SizedBox(height: 8),
          _healthRow(
            'API Error Rate',
            '${dp.stats.apiErrorRate.toStringAsFixed(2)}%',
            dp.stats.apiErrorRate < 1
                ? AdminColors.success
                : dp.stats.apiErrorRate < 5
                    ? AdminColors.warning
                    : AdminColors.error,
          ),
          const SizedBox(height: 8),
          _healthRow(
            'Avg Response',
            '${dp.stats.avgResponseTime.toStringAsFixed(0)}ms',
            dp.stats.avgResponseTime < 200
                ? AdminColors.success
                : dp.stats.avgResponseTime < 500
                    ? AdminColors.warning
                    : AdminColors.error,
          ),
          const SizedBox(height: 8),
          _healthRow(
            'DAU / MAU',
            '${_formatNumber(dp.stats.dau.toInt())} / ${_formatNumber(dp.stats.mau.toInt())}',
            AdminColors.info,
          ),
        ],
      ),
    );
  }

  Widget _healthRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textMedium,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        Icons.group,
        'Users',
        AdminColors.primary,
        () => widget.onNavigate('/users'),
      ),
      _QuickAction(
        Icons.checklist,
        'Approvals',
        AdminColors.warning,
        () => widget.onNavigate('/approvals'),
      ),
      _QuickAction(
        Icons.auto_awesome,
        'AI Factory',
        AdminColors.primaryLight,
        () => widget.onNavigate('/ai-factory'),
      ),
      _QuickAction(
        Icons.analytics,
        'Analytics',
        AdminColors.info,
        () => widget.onNavigate('/analytics'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminColors.textHigh,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map(
                (a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: a.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: a.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(a.icon, size: 22, color: a.color),
                            const SizedBox(height: 6),
                            Text(
                              a.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: a.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _formatAmount(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction(this.icon, this.label, this.color, this.onTap);
}
