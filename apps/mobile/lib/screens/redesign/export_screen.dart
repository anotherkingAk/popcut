import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/popcut_theme.dart';
import '../../services/project_service.dart';
import '../../models/project.dart';

class ExportScreenRedesign extends StatefulWidget {
  final String? projectId;
  final VoidCallback onBack;
  final void Function(String route) onNavigate;

  const ExportScreenRedesign({
    super.key,
    this.projectId,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<ExportScreenRedesign> createState() => _ExportScreenRedesignState();
}

class _ExportScreenRedesignState extends State<ExportScreenRedesign>
    with SingleTickerProviderStateMixin {
  String _resolution = '1080p';
  String _format = 'MP4';
  int _fps = 30;
  int _bitrate = 8000;
  bool _hdr = false;
  bool _watermark = true;
  bool _isExporting = false;
  late AnimationController _exportController;

  final _resolutions = ['720p', '1080p', '2K', '4K'];
  final _formats = ['MP4', 'MOV', 'GIF'];
  final _fpsOptions = [24, 30, 60];

  @override
  void initState() {
    super.initState();
    _exportController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _exportController.dispose();
    super.dispose();
  }

  Future<void> _startExport() async {
    setState(() => _isExporting = true);
    _exportController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      if (widget.projectId != null) {
        context
            .read<ProjectService>()
            .updateProject(widget.projectId!, status: ProjectStatus.done);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projectId != null
        ? context.watch<ProjectService>().getProject(widget.projectId!)
        : null;

    return Scaffold(
      backgroundColor: PopCutColors.background,
      appBar: AppBar(
        backgroundColor: PopCutColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: PopCutColors.textPrimary,
          onPressed: widget.onBack,
        ),
        title: Text(project?.name ?? 'Export'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: PopCutColors.glass(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PopCutColors.glassBorder()),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: PopCutColors.textSecondary),
                const SizedBox(width: 6),
                Text('Schedule',
                    style: PopCutTypography.captionBold.copyWith(
                      color: PopCutColors.textSecondary,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Resolution', style: PopCutTypography.headline),
            ),
            const SizedBox(height: 10),
            _buildResolutionSelector(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildFormatSelector()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFpsSelector()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildBitrateSlider(),
            const SizedBox(height: 20),
            _buildToggleRow('HDR', 'High Dynamic Range', _hdr, (v) {
              setState(() => _hdr = v);
            }),
            _buildToggleRow('Watermark', '"Made with PopCut"', _watermark, (v) {
              setState(() => _watermark = v);
            }),
            const SizedBox(height: 24),
            _buildExportButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: PopCutColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PopCutColors.border.withValues(alpha: 0.3)),
        boxShadow: PopCutShadows.card,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: PopCutColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.play_circle_outline_rounded,
                      size: 28, color: PopCutColors.primary),
                ),
                const SizedBox(height: 8),
                Text('Final Preview',
                    style: PopCutTypography.bodySmall.copyWith(
                      color: PopCutColors.textMuted,
                    )),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded,
                      size: 12, color: PopCutColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('$_resolution · ${_fps}fps',
                      style: PopCutTypography.caption.copyWith(
                        color: PopCutColors.textSecondary,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('~${(_bitrate ~/ 1000)}MB',
                  style: PopCutTypography.caption.copyWith(
                    color: PopCutColors.textSecondary,
                    fontSize: 10,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionSelector() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _resolutions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final res = _resolutions[i];
          final isSelected = _resolution == res;
          final icon = switch (res) {
            '720p' => Icons.hd_rounded,
            '1080p' => Icons.four_k_rounded,
            '2K' => Icons.four_k_plus_rounded,
            '4K' => Icons.enhanced_encryption_rounded,
            _ => Icons.hd_rounded,
          };
          return GestureDetector(
            onTap: () => setState(() => _resolution = res),
            child: Container(
              width: 84,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [PopCutColors.primary, Color(0xFF00B4D8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : PopCutColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? PopCutColors.primary
                      : PopCutColors.border.withValues(alpha: 0.3),
                  width: isSelected ? 1 : 0.5,
                ),
                boxShadow: isSelected ? PopCutShadows.glow : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 22,
                      color: isSelected
                          ? PopCutColors.background
                          : PopCutColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(res,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? PopCutColors.background
                            : PopCutColors.textPrimary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Format', style: PopCutTypography.captionBold),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: PopCutColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PopCutColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: _formats.map((f) {
              final isSelected = _format == f;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _format = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PopCutColors.primary.withValues(alpha: 0.15)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(f,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? PopCutColors.primary
                              : PopCutColors.textSecondary,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFpsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FPS', style: PopCutTypography.captionBold),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: PopCutColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PopCutColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: _fpsOptions.map((f) {
              final isSelected = _fps == f;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _fps = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PopCutColors.primary.withValues(alpha: 0.15)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$f',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? PopCutColors.primary
                              : PopCutColors.textSecondary,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBitrateSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bitrate', style: PopCutTypography.captionBold),
              Text('${_bitrate}kbps',
                  style: PopCutTypography.captionBold.copyWith(
                    color: PopCutColors.primary,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: PopCutColors.primary,
              inactiveTrackColor: PopCutColors.surfaceHover,
              thumbColor: PopCutColors.primary,
              overlayColor: PopCutColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: _bitrate.toDouble(),
              min: 1000,
              max: 50000,
              divisions: 49,
              label: '${_bitrate}kbps',
              onChanged: (v) => setState(() => _bitrate = v.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 Mbps',
                  style: PopCutTypography.caption.copyWith(fontSize: 10)),
              Text('50 Mbps',
                  style: PopCutTypography.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PopCutColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PopCutColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PopCutTypography.captionBold),
                const SizedBox(height: 2),
                Text(subtitle, style: PopCutTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PopCutColors.primary,
            activeTrackColor: PopCutColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: PopCutColors.textMuted,
            inactiveTrackColor: PopCutColors.surfaceHover,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _isExporting ? null : _startExport,
        child: AnimatedBuilder(
          animation: _exportController,
          builder: (context, child) {
            final progress = _exportController.value;
            final isComplete = _exportController.isCompleted;
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isComplete
                      ? [PopCutColors.success, const Color(0xFF16A34A)]
                      : [PopCutColors.primary, const Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isComplete
                            ? PopCutColors.success
                            : PopCutColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isExporting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                              value: isComplete ? 1.0 : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isComplete
                                ? 'Export Complete!'
                                : 'Exporting... ${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload_outlined,
                              size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Export Video',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
