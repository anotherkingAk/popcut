import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class TemplatesScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const TemplatesScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedCategory = 0;
  bool _isSearching = false;

  final _categories = ['Trending', 'New', 'Seasonal', 'Educational', 'Social Media', 'Business'];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: AppColors.textHigh, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search templates...',
                  hintStyle: TextStyle(color: AppColors.textLow),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Templates'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _focusNode.unfocus();
                } else {
                  _focusNode.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          const SizedBox(height: 4),
          Expanded(child: _buildTemplateGrid()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final isSelected = _selectedCategory == i;
          return GestureDetector(
            onTap: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _selectedCategory = i);
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
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.textHigh : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateGrid() {
    final filtered = _templates
        .where((t) => t.category == _categories[_selectedCategory])
        .toList();
    final searchQuery = _searchController.text.toLowerCase().trim();
    final displayed = searchQuery.isNotEmpty
        ? filtered.where((t) => t.name.toLowerCase().contains(searchQuery)).toList()
        : filtered;

    if (displayed.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text('No templates found', style: AppTypography.bodyMd),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayed.length,
      itemBuilder: (context, i) => _buildTemplateCard(displayed[i]),
    );
  }

  Widget _buildTemplateCard(_Template template) {
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        widget.onNavigate('/template-detail', args: {
          'templateId': template.id,
          'templateName': template.name,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: template.color.withValues(alpha: 0.15),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(template.icon, size: 36, color: template.color),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        children: [
                          if (template.isPro)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.brand500, AppColors.brand300],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textHigh, letterSpacing: 0.5)),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.bgOverlay,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(template.duration, style: const TextStyle(fontSize: 8, color: AppColors.textHigh)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgOverlay,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, size: 8, color: AppColors.warning),
                            const SizedBox(width: 3),
                            Text('${template.uses}', style: const TextStyle(fontSize: 8, color: AppColors.textHigh)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHigh),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${template.uses} uses',
                      style: const TextStyle(fontSize: 10, color: AppColors.textLow),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Template {
  final String id;
  final String name;
  final String duration;
  final String category;
  final IconData icon;
  final Color color;
  final int uses;
  final bool isPro;

  const _Template({
    required this.id,
    required this.name,
    required this.duration,
    required this.category,
    required this.icon,
    required this.color,
    required this.uses,
    this.isPro = false,
  });
}

const _templates = <_Template>[
  _Template(id: 't1', name: 'Vlog Intro', duration: '0:15', category: 'Trending', icon: Icons.play_circle, color: AppColors.primary, uses: 1240, isPro: false),
  _Template(id: 't2', name: 'Cinematic Opener', duration: '0:20', category: 'Trending', icon: Icons.movie, color: AppColors.error, uses: 980, isPro: true),
  _Template(id: 't3', name: 'Product Showcase', duration: '0:30', category: 'Trending', icon: Icons.shopping_bag, color: AppColors.trackAudio, uses: 2150, isPro: false),
  _Template(id: 't4', name: 'Travel Reel', duration: '0:12', category: 'New', icon: Icons.flight_takeoff, color: AppColors.trackText, uses: 540, isPro: false),
  _Template(id: 't5', name: 'Gaming Montage', duration: '0:45', category: 'New', icon: Icons.sports_esports, color: AppColors.warning, uses: 320, isPro: true),
  _Template(id: 't6', name: 'TikTok Compilation', duration: '0:10', category: 'New', icon: Icons.music_note, color: AppColors.textMedium, uses: 410, isPro: false),
  _Template(id: 't7', name: 'Diwali Greeting', duration: '0:15', category: 'Seasonal', icon: Icons.auto_awesome, color: AppColors.warning, uses: 3100, isPro: false),
  _Template(id: 't8', name: 'Christmas Card', duration: '0:10', category: 'Seasonal', icon: Icons.ac_unit, color: AppColors.textMedium, uses: 870, isPro: false),
  _Template(id: 't9', name: 'Tutorial Intro', duration: '0:08', category: 'Educational', icon: Icons.school, color: AppColors.textMedium, uses: 670, isPro: false),
  _Template(id: 't10', name: 'Lecture Recap', duration: '0:60', category: 'Educational', icon: Icons.menu_book, color: AppColors.textLow, uses: 230, isPro: true),
  _Template(id: 't11', name: 'Instagram Story', duration: '0:15', category: 'Social Media', icon: Icons.camera_alt, color: AppColors.trackText, uses: 5400, isPro: false),
  _Template(id: 't12', name: 'YouTube End Screen', duration: '0:20', category: 'Social Media', icon: Icons.videocam, color: AppColors.error, uses: 1900, isPro: false),
  _Template(id: 't13', name: 'LinkedIn Post', duration: '0:30', category: 'Business', icon: Icons.work, color: AppColors.primary, uses: 430, isPro: true),
  _Template(id: 't14', name: 'Corporate Pitch', duration: '0:45', category: 'Business', icon: Icons.business_center, color: AppColors.textMedium, uses: 180, isPro: true),
  _Template(id: 't15', name: 'Team Introduction', duration: '0:25', category: 'Business', icon: Icons.groups, color: AppColors.trackAudio, uses: 290, isPro: false),
  _Template(id: 't16', name: 'Eid Mubarak', duration: '0:12', category: 'Seasonal', icon: Icons.star, color: AppColors.textMedium, uses: 650, isPro: false),
];
