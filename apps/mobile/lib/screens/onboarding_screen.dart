import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = [
    _OnboardData('Edit in your language', 'Hindi, Tamil, Telugu, Marathi —\nAI captions that understand you', Icons.translate),
    _OnboardData('Made for Indian creators', 'Festival templates, regional music,\n₹99/month Pro', Icons.auto_awesome),
    _OnboardData('Edit offline, export anywhere', 'No internet needed. One-tap publish\nto Instagram, YouTube, Josh & Moj', Icons.wifi_off),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: () { HapticService.trigger(HapticLevel.light); widget.onComplete(); }, child: const Text('Skip', style: TextStyle(fontSize: 13, color: AppColors.foregroundSecondary))),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages.map((p) => _OnboardingPage(data: p)).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? AppColors.primary : AppColors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _page < 2
                          ? () { HapticService.trigger(HapticLevel.light); _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }
                          : () { HapticService.trigger(HapticLevel.light); widget.onComplete(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_page < 2 ? 'Next' : 'Get Started', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final IconData icon;
  _OnboardData(this.title, this.subtitle, this.icon);
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(data.icon, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          Text(data.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(data.subtitle, style: const TextStyle(fontSize: 15, color: AppColors.foregroundSecondary, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
