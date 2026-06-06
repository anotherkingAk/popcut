import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class ReelMakerScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String path) onComplete;

  const ReelMakerScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<ReelMakerScreen> createState() => _ReelMakerScreenState();
}

class _ReelMakerScreenState extends State<ReelMakerScreen> {
  bool _isRecording = false;
  bool _flashOn = false;
  bool _isFrontCamera = false;
  bool _beautyFilterOn = false;
  bool _showTrimView = false;
  double _speed = 1.0;
  int _countdown = 0;
  Timer? _countdownTimer;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  final List<ClipSegment> _clips = [];
  final TextEditingController _textOverlayCtl = TextEditingController();

  final List<double> _speeds = [0.5, 1.0, 2.0];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _textOverlayCtl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    HapticService.trigger(HapticLevel.light);
    setState(() => _countdown = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        _startRecording();
      } else {
        setState(() => --_countdown);
      }
    });
  }

  void _startRecording() {
    HapticService.trigger(HapticLevel.medium);
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => ++_recordingDuration);
    });
  }

  void _stopRecording() {
    HapticService.trigger(HapticLevel.light);
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _clips.add(ClipSegment(duration: _recordingDuration, speed: _speed));
      _showTrimView = true;
    });
  }

  void _toggleFlash() {
    HapticService.trigger(HapticLevel.light);
    setState(() => _flashOn = !_flashOn);
  }

  void _toggleCamera() {
    HapticService.trigger(HapticLevel.light);
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  void _toggleBeauty() {
    HapticService.trigger(HapticLevel.light);
    setState(() => _beautyFilterOn = !_beautyFilterOn);
  }

  void _setSpeed(double s) {
    HapticService.trigger(HapticLevel.light);
    setState(() => _speed = s);
  }

  @override
  Widget build(BuildContext context) {
    if (_showTrimView) return _buildTrimView();
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Stack(
          children: [
            _buildPreview(),
            _buildTopBar(),
            _buildRightSidebar(),
            _buildBottomControls(),
            if (_countdown > 0) _buildCountdownOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      color: AppColors.bgBase,
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          color: AppColors.bgElevated,
          child: Center(
            child: Icon(Icons.videocam_outlined, size: 48, color: AppColors.textLow.withValues(alpha: 0.4)),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.music_note_outlined, color: Colors.white),
              onPressed: () { HapticService.trigger(HapticLevel.light); },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.timer_outlined, color: Colors.white),
              onPressed: _startCountdown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Positioned(
      right: 12, top: 100,
      child: Column(
        children: [
          _sidebarButton(
            icon: Icons.speed,
            child: Text('${_speed}x', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
            onTap: () {
              final idx = _speeds.indexOf(_speed);
              _setSpeed(_speeds[(idx + 1) % _speeds.length]);
            },
          ),
          const SizedBox(height: 16),
          _sidebarButton(
            icon: _beautyFilterOn ? Icons.auto_awesome : Icons.auto_awesome_outlined,
            onTap: _toggleBeauty,
          ),
          const SizedBox(height: 16),
          _sidebarButton(
            icon: Icons.timer_outlined,
            onTap: _startCountdown,
          ),
          const SizedBox(height: 16),
          _sidebarButton(
            icon: Icons.blur_on_outlined,
            onTap: () { HapticService.trigger(HapticLevel.light); },
          ),
        ],
      ),
    );
  }

  Widget _sidebarButton({IconData? icon, Widget? child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.glassBase,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: child ?? Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40, left: 0, right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.flip_camera_android_outlined, color: Colors.white, size: 28),
            onPressed: _toggleCamera,
          ),
          const SizedBox(width: 40),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            onTap: () {
              if (_isRecording) _stopRecording();
            },
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  width: _isRecording ? 28 : 60,
                  height: _isRecording ? 28 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? AppColors.error : Colors.white,
                  ),
                  child: _isRecording
                      ? const Center(child: Icon(Icons.stop, color: Colors.white, size: 16))
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28),
            onPressed: _toggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Text(
            '$_countdown',
            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTrimView() {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showTrimView = false); },
        ),
        title: const Text('Trim', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () { HapticService.trigger(HapticLevel.light); widget.onComplete('/tmp/capcard_reel.mp4'); },
            child: const Text('Next', style: TextStyle(color: AppColors.brand500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.bgBase,
              child: Center(
                child: Icon(Icons.movie_outlined, size: 64, color: AppColors.textLow.withValues(alpha: 0.3)),
              ),
            ),
          ),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.bgElevated,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _clips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final clip = _clips[i];
                return Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('${clip.duration}s', style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.bgElevated,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_fields, color: Colors.white),
                  onPressed: () { HapticService.trigger(HapticLevel.light); _showTextOverlayDialog(); },
                ),
                const Spacer(),
                Text('${_clips.length} clip${_clips.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTextOverlayDialog() {
    HapticService.trigger(HapticLevel.light);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgOverlay,
        title: const Text('Add Text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _textOverlayCtl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            hintStyle: TextStyle(color: AppColors.textLow),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brand500)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); },
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.brand500)),
          ),
        ],
      ),
    );
  }
}

class ClipSegment {
  final int duration;
  final double speed;
  ClipSegment({required this.duration, required this.speed});
}
