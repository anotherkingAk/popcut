import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminContentScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AdminContentScreen({super.key, required this.onBack});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  String _selectedTab = 'All';
  final Set<int> _selectedItems = {};
  bool _bulkMode = false;

  final _tabs = ['All', 'Reported', 'Flagged', 'Auto-detected'];

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
        title: Text(_bulkMode ? '${_selectedItems.length} selected' : 'Content Moderation'),
        actions: [
          IconButton(
            icon: Icon(_bulkMode ? Icons.close : Icons.checklist),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              setState(() {
                _bulkMode = !_bulkMode;
                if (!_bulkMode) _selectedItems.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          if (_bulkMode && _selectedItems.isNotEmpty)
            _buildBulkActionBar(),
          Expanded(child: _buildContentList()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedTab == _tabs[i];
          return GestureDetector(
            onTap: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _selectedTab = _tabs[i]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brand500 : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.brand500 : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.textHigh : AppColors.textMedium,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.medium);
                setState(() => _selectedItems.clear());
              },
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Approve All', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.medium);
                setState(() => _selectedItems.clear());
              },
              icon: const Icon(Icons.block_outlined, size: 16),
              label: const Text('Reject All', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _contentItems.length,
      itemBuilder: (_, i) {
        final item = _contentItems[i];
        final isSelected = _selectedItems.contains(i);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.brand500 : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_bulkMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticService.trigger(HapticLevel.light);
                            setState(() {
                              if (isSelected) {
                                _selectedItems.remove(i);
                              } else {
                                _selectedItems.add(i);
                              }
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brand500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? AppColors.brand500 : AppColors.textLow,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 14, color: AppColors.textHigh)
                                : null,
                          ),
                        ),
                      ),
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.movie_outlined, size: 28, color: item.color),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.bgOverlay,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(item.duration, style: const TextStyle(fontSize: 8, color: AppColors.textHigh)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHigh),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 12, color: AppColors.textLow),
                              const SizedBox(width: 4),
                              Text(item.creator, style: const TextStyle(fontSize: 11, color: AppColors.textLow)),
                              const SizedBox(width: 8),
                              Icon(Icons.flag_outlined, size: 12, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text('${item.reportCount} reports', style: const TextStyle(fontSize: 11, color: AppColors.warning)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            children: item.reasons.map((r) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r,
                                style: const TextStyle(fontSize: 9, color: AppColors.error),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    if (!_bulkMode) ...[
                      SizedBox(
                        width: 48,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textLow),
                          onSelected: (value) {
                            HapticService.trigger(HapticLevel.light);
                          },
                          color: AppColors.bgSurface,
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'approve', child: Text('Approve', style: TextStyle(color: AppColors.success, fontSize: 13))),
                            const PopupMenuItem(value: 'reject', child: Text('Reject', style: TextStyle(color: AppColors.error, fontSize: 13))),
                            const PopupMenuItem(value: 'flag', child: Text('Flag', style: TextStyle(color: AppColors.warning, fontSize: 13))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!_bulkMode)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticService.trigger(HapticLevel.medium);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 14),
                          label: const Text('Approve', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticService.trigger(HapticLevel.medium);
                          },
                          icon: const Icon(Icons.block_outlined, size: 14),
                          label: const Text('Reject', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticService.trigger(HapticLevel.light);
                          },
                          icon: const Icon(Icons.flag_outlined, size: 14),
                          label: const Text('Flag', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentItem {
  final String title;
  final String creator;
  final String duration;
  final Color color;
  final int reportCount;
  final List<String> reasons;

  const _ContentItem({
    required this.title,
    required this.creator,
    required this.duration,
    required this.color,
    required this.reportCount,
    required this.reasons,
  });
}

const _contentItems = <_ContentItem>[
  _ContentItem(title: 'Summer Vibes Compilation', creator: 'Creator_123', duration: '0:45', color: AppColors.primary, reportCount: 3, reasons: ['Copyright', 'TOS Violation']),
  _ContentItem(title: 'Gaming Montage Episode 5', creator: 'GamerPro', duration: '1:20', color: AppColors.trackAudio, reportCount: 1, reasons: ['Spam']),
  _ContentItem(title: 'Product Review - Suspicious', creator: 'ReviewerXYZ', duration: '0:30', color: AppColors.error, reportCount: 8, reasons: ['Misleading', 'Spam', 'Fake']),
  _ContentItem(title: 'TikTok Dance Compilation', creator: 'DanceQueen', duration: '0:15', color: AppColors.trackText, reportCount: 2, reasons: ['Inappropriate']),
  _ContentItem(title: 'AI Generated Advert', creator: 'BizBoost', duration: '0:60', color: AppColors.warning, reportCount: 5, reasons: ['Misinformation', 'Undeclared AI']),
  _ContentItem(title: 'Tutorial - Unauthorized', creator: 'EduCreator22', duration: '0:25', color: AppColors.textMedium, reportCount: 1, reasons: ['Copyright']),
  _ContentItem(title: 'Music Video Preview', creator: 'IndieArtist', duration: '0:40', color: AppColors.textMedium, reportCount: 4, reasons: ['Copyright', 'TOS Violation', 'Explicit']),
  _ContentItem(title: 'Vlog Controversial Topic', creator: 'VloggerOne', duration: '0:55', color: AppColors.textMedium, reportCount: 2, reasons: ['Hate speech']),
];
