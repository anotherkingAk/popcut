import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AiCaptioningWizard extends StatefulWidget {
  final VoidCallback onClose;
  const AiCaptioningWizard({super.key, required this.onClose});

  @override
  State<AiCaptioningWizard> createState() => _AiCaptioningWizardState();
}

class _AiCaptioningWizardState extends State<AiCaptioningWizard> with SingleTickerProviderStateMixin {
  int _step = 0;
  String _selectedLanguage = 'English';
  double _progress = 0;
  late AnimationController _progressController;
  final List<TextEditingController> _captionControllers = [];

  final _languages = [
    'English', 'Hindi', 'Tamil', 'Telugu', 'Marathi',
    'Bengali', 'Gujarati', 'Kannada', 'Malayalam', 'Punjabi',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _progressController.dispose();
    for (final c in _captionControllers) c.dispose();
    super.dispose();
  }

  void _startProcessing() {
    setState(() => _step = 1);
    _progressController.forward().then((_) {
      if (mounted) setState(() => _step = 2);
    });
    _progressController.addListener(() {
      setState(() => _progress = _progressController.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: switch (_step) {
              0 => _buildLanguageStep(),
              1 => _buildProcessingStep(),
              2 => _buildReviewStep(),
              _ => const SizedBox(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          const Text('Auto Captions', style: AppTypography.titleSm),
          const Spacer(),
          _buildStepIndicator(),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textLow,
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) => Container(
        width: _step == i ? 20 : 6,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: i <= _step ? AppColors.brand500 : AppColors.textLow,
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Select Language', style: AppTypography.titleMd),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Choose the language of your video audio', style: AppTypography.bodyMd),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _languages.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _selectedLanguage = _languages[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: _selectedLanguage == _languages[i] ? AppColors.brand500.withValues(alpha: 0.1) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedLanguage == _languages[i] ? AppColors.brand500 : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, size: 18, color: _selectedLanguage == _languages[i] ? AppColors.brand500 : AppColors.textLow),
                    const SizedBox(width: 12),
                    Text(_languages[i], style: TextStyle(
                      fontSize: 14,
                      color: _selectedLanguage == _languages[i] ? AppColors.textHigh : AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    )),
                    const Spacer(),
                    if (['Hindi', 'English'].contains(_languages[i]))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Popular', style: TextStyle(fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Auto-detect', style: TextStyle(color: AppColors.textMedium)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _startProcessing,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80, height: 80,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 4,
                color: AppColors.brand500,
                backgroundColor: AppColors.timelineGrid,
              ),
            ),
            const SizedBox(height: 24),
            Text('${(_progress * 100).toInt()}%', style: AppTypography.displaySm),
            const SizedBox(height: 8),
            Text(
              _progress < 0.3
                  ? 'Transcribing audio...'
                  : _progress < 0.7
                      ? 'Generating timestamps...'
                      : 'Applying captions...',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: 8),
            Text('About ${(30 - _progress * 30).toInt()} seconds remaining',
                style: AppTypography.bodySm),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() {
                _step = 0;
                _progressController.reset();
              }),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textLow)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final captions = [
      _Caption(text: 'Welcome to PopCut', time: '0:05 - 0:08'),
      _Caption(text: 'The AI-powered video editor', time: '0:08 - 0:12'),
      _Caption(text: 'That makes creation effortless', time: '0:12 - 0:15'),
      _Caption(text: 'Edit, enhance, and export', time: '0:15 - 0:18'),
      _Caption(text: 'In just a few taps', time: '0:18 - 0:21'),
    ];

    if (_captionControllers.isEmpty) {
      for (final c in captions) {
        _captionControllers.add(TextEditingController(text: c.text));
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Style: Default', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
              ),
              const Spacer(),
              Text('${captions.length} captions', style: AppTypography.bodySm),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: captions.length,
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _captionControllers[i],
                          style: const TextStyle(fontSize: 13, color: AppColors.textHigh),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                          ),
                        ),
                        Text(captions[i].time, style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.play_arrow, size: 16), color: AppColors.textMedium, onPressed: () {}),
                  IconButton(icon: const Icon(Icons.close, size: 14), color: AppColors.textLow, onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Style', style: TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  HapticService.trigger(HapticLevel.success);
                  widget.onClose();
                },
                child: const Text('Apply to Timeline'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Caption {
  final String text;
  final String time;
  _Caption({required this.text, required this.time});
}
