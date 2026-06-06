import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AdminAnalyticsScreen({super.key, required this.onBack});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedRange = '7d';

  final _ranges = ['24h', '7d', '30d', '90d', '1y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticService.trigger(HapticLevel.light);
            widget.onBack();
          },
        ),
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 20),
            _buildMetricCards(),
            const SizedBox(height: 24),
            Text('Users Over Time', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildChartPlaceholder(
              icon: Icons.trending_up,
              label: 'DAU: 843  •  MAU: 2,104',
              color: AppColors.brand500,
            ),
            const SizedBox(height: 24),
            Text('Revenue', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildChartPlaceholder(
              icon: Icons.attach_money,
              label: '\$12,430 this period',
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text('Feature Usage', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildFeatureUsage(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticService.trigger(HapticLevel.medium);
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export Full Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _ranges.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticService.trigger(HapticLevel.light);
                setState(() => _selectedRange = range);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brand500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.textHigh : AppColors.textMedium,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCards() {
    final metrics = [
      {'label': 'DAU', 'value': '843', 'change': '+12%', 'color': AppColors.brand500},
      {'label': 'MAU', 'value': '2.1K', 'change': '+8%', 'color': AppColors.info},
      {'label': 'Revenue', 'value': '\$12.4K', 'change': '+23%', 'color': AppColors.success},
      {'label': 'Retention', 'value': '68%', 'change': '+3%', 'color': AppColors.warning},
      {'label': 'Conversion', 'value': '5.2%', 'change': '+0.8%', 'color': AppColors.trackAudio},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final m = metrics[i];
          final color = m['color'] as Color;
          return Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                const SizedBox(height: 4),
                Text(
                  m['value'] as String,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      (m['change'] as String).startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      m['change'] as String,
                      style: TextStyle(fontSize: 10, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartPlaceholder({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
          const SizedBox(height: 4),
          Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomPaint(
              painter: _ChartLinePainter(color.withValues(alpha: 0.3), color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureUsage() {
    final features = [
      {'name': 'Auto Captions', 'usage': 0.85, 'color': AppColors.trackAudio},
      {'name': 'Beat Sync', 'usage': 0.65, 'color': AppColors.trackVideo},
      {'name': 'Text to Video', 'usage': 0.45, 'color': AppColors.brand500},
      {'name': 'Voice Clone', 'usage': 0.30, 'color': AppColors.trackText},
      {'name': 'Smart Crop', 'usage': 0.55, 'color': AppColors.trackOverlay},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: features.map((f) {
          final name = f['name'] as String;
          final usage = f['usage'] as double;
          final color = f['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
                    Text('${(usage * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usage,
                    backgroundColor: AppColors.bgElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartLinePainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;

  _ChartLinePainter(this.lineColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.2),
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final points = [0.3, 0.5, 0.4, 0.7, 0.55, 0.8, 0.65, 0.9, 0.75, 0.85];

    path.moveTo(0, size.height * (1 - points[0]));
    for (int i = 1; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * (1 - points[i]);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
