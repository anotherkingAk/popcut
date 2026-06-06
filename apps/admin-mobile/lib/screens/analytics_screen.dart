import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const AnalyticsScreen({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dp = context.read<DashboardProvider>();
      if (dp.stats.totalUsers == 0) {
        dp.fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerWidget(
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dp, _) {
          if (dp.isLoading && dp.stats.totalUsers == 0) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyMetrics(dp),
                const SizedBox(height: 20),
                _buildRevenueChart(dp),
                const SizedBox(height: 20),
                _buildDauChart(dp),
                const SizedBox(height: 20),
                _buildMauChart(dp),
                const SizedBox(height: 20),
                _buildSignupsChart(dp),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyMetrics(DashboardProvider dp) {
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
            'Key Metrics',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metricItem(
                'DAU',
                dp.stats.dau.toInt().toString(),
                AdminColors.primary,
                Icons.people,
              ),
              _metricItem(
                'MAU',
                dp.stats.mau.toInt().toString(),
                AdminColors.success,
                Icons.people_outline,
              ),
              _metricItem(
                'Revenue',
                '\$${_formatAmount(dp.stats.revenueThisYear)}',
                AdminColors.warning,
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricItem(
                'Total Users',
                _formatNumber(dp.stats.totalUsers),
                AdminColors.info,
                Icons.group,
              ),
              _metricItem(
                'Exports',
                _formatNumber(dp.stats.exportsThisMonth),
                AdminColors.primaryLight,
                Icons.file_upload,
              ),
              _metricItem(
                'New Today',
                _formatNumber(dp.stats.newUsersToday),
                AdminColors.success,
                Icons.person_add,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AdminColors.textLow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(DashboardProvider dp) {
    final points = dp.chartData.revenueHistory;
    if (points.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'Revenue History',
      _LineChartWidget(
        points: points
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
            .toList(),
        color: AdminColors.warning,
        formatY: (v) => '\$${v.toInt()}',
        bottomLabels: points.asMap().entries.map((e) {
          final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
          return days[e.value.date.weekday - 1];
        }).toList(),
      ),
    );
  }

  Widget _buildDauChart(DashboardProvider dp) {
    final points = dp.chartData.dauHistory;
    if (points.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'Daily Active Users',
      _LineChartWidget(
        points: points
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
            .toList(),
        color: AdminColors.primary,
        formatY: (v) => v.toInt().toString(),
        bottomLabels: points.asMap().entries.map((e) {
          final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
          return days[e.value.date.weekday - 1];
        }).toList(),
      ),
    );
  }

  Widget _buildMauChart(DashboardProvider dp) {
    final points = dp.chartData.mauHistory;
    if (points.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'Monthly Active Users',
      _LineChartWidget(
        points: points
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
            .toList(),
        color: AdminColors.success,
        formatY: (v) => v.toInt().toString(),
        bottomLabels: points.asMap().entries.map((e) {
          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          return months[e.value.date.month - 1];
        }).toList(),
      ),
    );
  }

  Widget _buildSignupsChart(DashboardProvider dp) {
    final points = dp.chartData.signupsHistory;
    if (points.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'New Signups',
      _BarChartWidget(
        points: points
            .asMap()
            .entries
            .map((e) => _BarData(e.key.toDouble(), e.value.count.toDouble()))
            .toList(),
        color: AdminColors.info,
        formatY: (v) => v.toInt().toString(),
        bottomLabels: points.asMap().entries.map((e) {
          final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
          return days[e.value.date.weekday - 1];
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
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

class _LineChartWidget extends StatelessWidget {
  final List<FlSpot> points;
  final Color color;
  final String Function(double) formatY;
  final List<String> bottomLabels;

  const _LineChartWidget({
    required this.points,
    required this.color,
    required this.formatY,
    required this.bottomLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final values = points.map((p) => p.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final adjustedMin = minY * 0.9;
    final adjustedMax = maxY == 0 ? 100 : maxY * 1.1;

    return LineChart(
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  formatY(value),
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
                if (idx < 0 || idx >= bottomLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    bottomLabels[idx],
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
        minY: adjustedMin,
        maxY: adjustedMax.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                formatY(spot.y),
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
    );
  }
}

class _BarData {
  final double x;
  final double y;
  _BarData(this.x, this.y);
}

class _BarChartWidget extends StatelessWidget {
  final List<_BarData> points;
  final Color color;
  final String Function(double) formatY;
  final List<String> bottomLabels;

  const _BarChartWidget({
    required this.points,
    required this.color,
    required this.formatY,
    required this.bottomLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final values = points.map((p) => p.y).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final adjustedMax = maxY == 0 ? 100 : maxY * 1.1;

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: adjustedMax / 4,
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
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  formatY(value),
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
                if (idx < 0 || idx >= bottomLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    bottomLabels[idx],
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
        maxY: adjustedMax.toDouble(),
        barGroups: points.map((p) {
          return BarChartGroupData(
            x: p.x.toInt(),
            barRods: [
              BarChartRodData(
                toY: p.y,
                color: color,
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                formatY(rod.toY),
                const TextStyle(
                  color: AdminColors.textHigh,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const DrawerWidget({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AdminColors.primaryDim, AdminColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.admin_panel_settings,
                    size: 32, color: Colors.white),
                SizedBox(height: 12),
                Text('PopCut Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Control your ecosystem',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _item(Icons.dashboard, 'Dashboard', '/dashboard'),
          _item(Icons.group, 'Users', '/users'),
          _item(Icons.checklist, 'Approvals', '/approvals'),
          _item(Icons.auto_awesome, 'AI Factory', '/ai-factory'),
          _item(Icons.notifications, 'Notifications', '/notifications'),
          _item(Icons.analytics, 'Analytics', '/analytics',
              selected: true),
          _item(Icons.settings, 'Settings', '/settings'),
        ],
      ),
    );
  }

  ListTile _item(IconData icon, String label, String route,
      {bool selected = false}) {
    return ListTile(
      leading: Icon(icon,
          size: 20,
          color: selected ? AdminColors.primary : AdminColors.textMedium),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              color:
                  selected ? AdminColors.primary : AdminColors.textHigh)),
      onTap: () => onNavigate(route),
    );
  }
}
