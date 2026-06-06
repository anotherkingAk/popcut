import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/haptic_service.dart';

class ExportScreen extends StatefulWidget {
  final String? projectId;
  final VoidCallback onBack;
  final void Function(String route) onNavigate;

  const ExportScreen({
    super.key,
    this.projectId,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> with SingleTickerProviderStateMixin {
  String _resolution = '1080p';
  String _framerate = '30fps';
  String _format = 'MP4';
  String _quality = 'High';
  bool _enableAiEnhance = true;
  bool _enableAutoCaption = true;
  bool _watermarkEnabled = true;
  late AnimationController _exportBtnController;
  bool _isExporting = false;

  final _platforms = [
    _Platform('Instagram', Icons.camera_alt, false),
    _Platform('YouTube', Icons.videocam, false),
    _Platform('Josh', Icons.music_note, true),
    _Platform('Moj', Icons.play_circle, true),
    _Platform('ShareChat', Icons.chat, true),
  ];

  @override
  void initState() {
    super.initState();
    _exportBtnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _exportBtnController.dispose();
    super.dispose();
  }

  Future<void> _startExport() async {
    setState(() => _isExporting = true);
    _exportBtnController.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      if (widget.projectId != null) {
        context.read<ProjectService>().updateProject(widget.projectId!, status: ProjectStatus.done);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projectId != null
        ? context.watch<ProjectService>().getProject(widget.projectId!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); }),
        title: Text(project?.name ?? 'Export'),
        actions: [
          TextButton(
            onPressed: () { HapticService.trigger(HapticLevel.light); },
            child: const Text('Schedule', style: TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            const SizedBox(height: 20),
            const Text('Platform', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 10),
            _buildPlatformRow(),
            const SizedBox(height: 24),
            const Text('Export Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _buildSetting('Resolution', _resolution, ['720p', '1080p', '2K', '4K']),
            _buildSetting('Frame Rate', _framerate, ['24fps', '25fps', '30fps', '60fps']),
            _buildSetting('Format', _format, ['MP4', 'MOV', 'GIF']),
            _buildSetting('Quality', _quality, ['Low', 'Medium', 'High', 'Very High']),
            const SizedBox(height: 24),
            const Text('Enhancements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _buildToggle('AI Enhancement', 'Auto color grade, stabilize, denoise', _enableAiEnhance, (v) { HapticService.trigger(HapticLevel.selection); setState(() => _enableAiEnhance = v); }),
            _buildToggle('AI Captions', 'Generate captions in Hindi/English', _enableAutoCaption, (v) { HapticService.trigger(HapticLevel.selection); setState(() => _enableAutoCaption = v); }),
            _buildToggle('Watermark', '"Made with PopCut"', _watermarkEnabled, (v) { HapticService.trigger(HapticLevel.selection); setState(() => _watermarkEnabled = v); }),
            const SizedBox(height: 24),
            _buildExportButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 48, color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 8),
                Text('Final Preview', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ),
          Positioned(
            bottom: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 10, color: AppColors.foregroundSecondary),
                  SizedBox(width: 4),
                  Text('1080p · 30fps · 0:45', style: TextStyle(fontSize: 9, color: AppColors.foregroundSecondary)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: const Text('~45 MB', style: TextStyle(fontSize: 9, color: AppColors.foregroundSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformRow() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _platforms.length,
        itemBuilder: (context, i) {
          final p = _platforms[i];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.isNew ? AppColors.caution : AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(p.icon, size: 20, color: p.isNew ? AppColors.caution : AppColors.foregroundSecondary),
                const SizedBox(height: 4),
                Text(p.name, style: TextStyle(fontSize: 10, color: p.isNew ? AppColors.caution : AppColors.foregroundSecondary)),
                if (p.isNew)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.caution, borderRadius: BorderRadius.circular(2)),
                    child: const Text('NEW', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSetting(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.foregroundSecondary)),
          const Spacer(),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.surfaceElevated,
            style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
            underline: const SizedBox(),
            icon: const Icon(Icons.chevron_right, size: 16, color: AppColors.foregroundMuted),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  if (label == 'Resolution') _resolution = v;
                  if (label == 'Frame Rate') _framerate = v;
                  if (label == 'Format') _format = v;
                  if (label == 'Quality') _quality = v;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.foregroundSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            inactiveThumbColor: AppColors.foregroundMuted,
            inactiveTrackColor: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: _isExporting ? null : () { HapticService.trigger(HapticLevel.medium); _startExport(); },
      child: AnimatedBuilder(
        animation: _exportBtnController,
        builder: (context, child) {
          final isComplete = _exportBtnController.isCompleted;
          return Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isComplete
                    ? [AppColors.constructive, AppColors.textMedium]
                    : [AppColors.primary, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isComplete ? AppColors.constructive : AppColors.primary).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isExporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                            value: _exportBtnController.value,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isComplete ? 'Export Complete!' : 'Exporting... ${(_exportBtnController.value * 100).toInt()}%',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload_outlined, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Export Video', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Platform {
  final String name;
  final IconData icon;
  final bool isNew;
  _Platform(this.name, this.icon, this.isNew);
}
