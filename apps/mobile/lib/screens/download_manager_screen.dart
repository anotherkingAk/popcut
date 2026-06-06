import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class DownloadManagerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DownloadManagerScreen({super.key, required this.onBack});

  @override
  State<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _cellularEnabled = true;
  bool _autoDownloadTemplates = false;
  double _maxConcurrent = 3.0;

  final _activeDownloads = List.generate(3, (i) => DownloadItem(
    name: ['Cinematic Transition Pack', 'Retro Font Collection', 'VHS Overlay Effects'][i],
    size: '${(i + 1) * 50} MB',
    progress: [0.45, 0.72, 0.15][i],
    speed: '${(i + 1) * 2}.${(i + 2)} MB/s',
    eta: ['1m 24s', '45s', '3m 12s'][i],
    status: DownloadStatus.downloading,
  ));

  final _completedDownloads = List.generate(5, (i) => DownloadItem(
    name: ['Wedding Template', 'Travel Vlog Pack', 'Gaming Overlays', 'LUT Color Pack', 'Sound Effects Bundle'][i],
    size: '${(i + 2) * 25} MB',
    progress: 1.0,
    speed: '-',
    eta: '-',
    status: DownloadStatus.completed,
    date: '${i + 1}d ago',
  ));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); }),
        title: const Text('Downloads'),
        bottom: const TabBar(
          indicatorColor: AppColors.brand500,
          labelColor: AppColors.brand500,
          unselectedLabelColor: AppColors.textLow,
          tabs: [
            Tab(text: 'Downloads'),
            Tab(text: 'Available'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDownloadsTab(),
          _buildAvailableTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildDownloadsTab() {
    if (_activeDownloads.isEmpty && _completedDownloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_outlined, size: 64, color: AppColors.textLow.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No downloads yet', style: AppTypography.titleSm),
            const SizedBox(height: 4),
            Text('Download templates and effects from the marketplace', style: AppTypography.bodyMd),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStorageBar(),
        const SizedBox(height: 20),
        if (_activeDownloads.isNotEmpty) ...[
          Text('Active Downloads', style: AppTypography.titleSm),
          const SizedBox(height: 10),
          for (final d in _activeDownloads) ...[
            _buildActiveItem(d),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
        ],
        if (_completedDownloads.isNotEmpty) ...[
          Text('Completed', style: AppTypography.titleSm),
          const SizedBox(height: 10),
          for (final d in _completedDownloads) ...[
            _buildCompletedItem(d),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }

  Widget _buildStorageBar() {
    final used = 2.4;
    final total = 10.0;
    final fraction = used / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Storage', style: AppTypography.titleSm),
              Text('Used $used GB of $total GB', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.bgOverlay,
              valueColor: const AlwaysStoppedAnimation(AppColors.brand500),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _storageLegend('Templates', 0.4, AppColors.trackVideo),
              const SizedBox(width: 12),
              _storageLegend('Fonts', 0.15, AppColors.trackAudio),
              const SizedBox(width: 12),
              _storageLegend('Effects', 0.25, AppColors.trackEffect),
              const SizedBox(width: 12),
              _storageLegend('Projects', 0.2, AppColors.trackText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _storageLegend(String label, double pct, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        margin: const EdgeInsets.only(right: 4)),
        Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }

  Widget _buildActiveItem(DownloadItem d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(d.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: () { HapticService.trigger(HapticLevel.light); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    d.status == DownloadStatus.paused ? Icons.play_arrow : Icons.pause,
                    size: 14, color: AppColors.textMedium,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticService.trigger(HapticLevel.light);
                  setState(() => _activeDownloads.remove(d));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 14, color: AppColors.textLow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: d.progress,
              minHeight: 4,
              backgroundColor: AppColors.bgOverlay,
              valueColor: AlwaysStoppedAnimation(
                d.status == DownloadStatus.paused ? AppColors.textLow : AppColors.brand500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(d.size, style: AppTypography.bodySm),
              const SizedBox(width: 12),
              Text(d.speed, style: AppTypography.bodySm),
              const SizedBox(width: 12),
              Text('ETA: ${d.eta}', style: AppTypography.bodySm),
              const Spacer(),
              Text('${(d.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedItem(DownloadItem d) {
    return Dismissible(
      key: ValueKey(d.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) { HapticService.trigger(HapticLevel.heavy); setState(() => _completedDownloads.remove(d)); },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(d.size, style: AppTypography.bodySm),
                      if (d.date != null) ...[
                        const SizedBox(width: 8),
                        Text(d.date!, style: AppTypography.bodySm),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () { HapticService.trigger(HapticLevel.light); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brand500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('View', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTab() {
    final availItems = ['Pro Color LUTs', 'Cinematic Font Pack', 'Glitch Transitions', 'Particle Overlays'];
    if (availItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_download_outlined, size: 64, color: AppColors.textLow.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('All assets downloaded', style: AppTypography.titleSm),
            const SizedBox(height: 4),
            Text('Check the marketplace for more', style: AppTypography.bodyMd),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: availItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(availItems[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${(i + 1) * 30} MB', style: AppTypography.bodySm),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () { HapticService.trigger(HapticLevel.light); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brand500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Download', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _settingTile(
          'Download over Cellular',
          'Allow downloads on mobile data',
          Switch(
            value: _cellularEnabled,
            onChanged: (v) { HapticService.trigger(HapticLevel.light); setState(() => _cellularEnabled = v); },
          ),
        ),
        const SizedBox(height: 4),
        _settingTile(
          'Auto-download Templates',
          'Automatically download new templates',
          Switch(
            value: _autoDownloadTemplates,
            onChanged: (v) { HapticService.trigger(HapticLevel.light); setState(() => _autoDownloadTemplates = v); },
          ),
        ),
        const SizedBox(height: 4),
        _settingTile(
          'Max Concurrent Downloads',
          'Maximum simultaneous downloads',
          SizedBox(
            width: 120,
            child: Slider(
              value: _maxConcurrent,
              min: 1, max: 5, divisions: 4,
              onChanged: (v) { HapticService.trigger(HapticLevel.light); setState(() => _maxConcurrent = v); },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text('Current: ${_maxConcurrent.toInt()}', style: AppTypography.bodySm),
          ),
        ),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticService.trigger(HapticLevel.medium);
              _showClearCacheDialog();
            },
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text('Clear All Cache (${_totalCacheSize()})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _totalCacheSize() {
    return '1.8 GB';
  }

  Widget _settingTile(String title, String subtitle, Widget trailing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: AppTypography.bodySm),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgOverlay,
        title: const Text('Clear Cache?', style: TextStyle(color: Colors.white)),
        content: const Text('This will remove all downloaded assets. You can download them again anytime.',
            style: TextStyle(color: AppColors.textMedium)),
        actions: [
          TextButton(
            onPressed: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); },
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

enum DownloadStatus { downloading, paused, completed, failed }

class DownloadItem {
  final String name;
  final String size;
  final double progress;
  final String speed;
  final String eta;
  final DownloadStatus status;
  final String? date;

  DownloadItem({
    required this.name,
    required this.size,
    required this.progress,
    required this.speed,
    required this.eta,
    required this.status,
    this.date,
  });
}
