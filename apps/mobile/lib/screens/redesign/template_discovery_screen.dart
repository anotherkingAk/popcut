import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import '../../widgets/redesign/popcut_card.dart';
import '../../widgets/redesign/popcut_search_bar.dart';
import '../../widgets/redesign/popcut_grid.dart';

class TemplateDiscoveryScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const TemplateDiscoveryScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<TemplateDiscoveryScreen> createState() =>
      _TemplateDiscoveryScreenState();
}

class _TemplateDiscoveryScreenState extends State<TemplateDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _showSearch = false;

  final _categories = [
    'For You', 'Trending', 'Gaming', 'Business',
    'Wedding', 'Travel', 'Education',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: _showSearch
            ? PopCutSearchBar(
                controller: _searchController,
                hintText: 'Search templates...',
                autofocus: true,
              )
            : const Text('Templates'),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: PopCutColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 44,
            margin: const EdgeInsets.only(top: 4),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [PopCutColors.primary, Color(0xFF00B4D8)],
                ),
              ),
              labelColor: PopCutColors.background,
              unselectedLabelColor: PopCutColors.textSecondary,
              labelStyle: PopCutTypography.captionBold.copyWith(fontSize: 13),
              unselectedLabelStyle: PopCutTypography.bodySmall.copyWith(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: _categories
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(c),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories
                  .map((category) => _buildTemplateGrid(category))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid(String category) {
    final filtered = _templates
        .where((t) => t.category == category)
        .toList();

    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase().trim();
      return _buildGrid(filtered
          .where((t) => t.name.toLowerCase().contains(q))
          .toList());
    }

    return _buildGrid(filtered);
  }

  Widget _buildGrid(List<_Template> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: PopCutColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No templates found', style: PopCutTypography.body),
          ],
        ),
      );
    }

    return PopCutGrid(
      itemCount: items.length,
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      isLoading: _isLoading,
      skeletonCount: 4,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, i) => _buildTemplateCard(items[i]),
    );
  }

  Widget _buildTemplateCard(_Template template) {
    return PopCutCard(
      padding: EdgeInsets.zero,
      backgroundColor: PopCutColors.surface,
      onTap: () => widget.onNavigate(
        '/template-detail',
        args: {
          'templateId': template.id,
          'templateName': template.name,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview thumbnail area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    template.color.withValues(alpha: 0.2),
                    template.color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: template.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(template.icon,
                          size: 24, color: template.color),
                    ),
                  ),
                  // Badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (template.isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('PRO',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                )),
                          ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: PopCutColors.background.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(template.duration,
                              style: const TextStyle(
                                  fontSize: 8, color: PopCutColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PopCutColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(template.category,
                          style: TextStyle(
                            fontSize: 8,
                            color: PopCutColors.primary,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info area
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(template.name,
                      style: PopCutTypography.captionBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded,
                          size: 10, color: PopCutColors.warning),
                      const SizedBox(width: 3),
                      Text('${template.uses}',
                          style: PopCutTypography.caption),
                      const Spacer(),
                      Icon(Icons.star_rounded,
                          size: 10,
                          color: PopCutColors.textMuted.withValues(alpha: 0.5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

final _templates = <_Template>[
  _Template(id: 't1', name: 'Vlog Intro', duration: '0:15', category: 'For You', icon: Icons.play_circle_rounded, color: PopCutColors.primary, uses: 1240),
  _Template(id: 't2', name: 'Cinematic Opener', duration: '0:20', category: 'For You', icon: Icons.movie_rounded, color: PopCutColors.secondary, uses: 980, isPro: true),
  _Template(id: 't3', name: 'Product Showcase', duration: '0:30', category: 'Trending', icon: Icons.shopping_bag_rounded, color: PopCutColors.success, uses: 2150),
  _Template(id: 't4', name: 'Travel Reel', duration: '0:12', category: 'Trending', icon: Icons.flight_rounded, color: PopCutColors.primary, uses: 540),
  _Template(id: 't5', name: 'Gaming Montage', duration: '0:45', category: 'Gaming', icon: Icons.sports_esports_rounded, color: PopCutColors.error, uses: 320, isPro: true),
  _Template(id: 't6', name: 'Highlights Reel', duration: '0:30', category: 'Gaming', icon: Icons.auto_awesome_rounded, color: PopCutColors.secondary, uses: 410),
  _Template(id: 't7', name: 'Corporate Pitch', duration: '0:45', category: 'Business', icon: Icons.business_rounded, color: PopCutColors.warning, uses: 180, isPro: true),
  _Template(id: 't8', name: 'Product Launch', duration: '0:25', category: 'Business', icon: Icons.rocket_rounded, color: PopCutColors.success, uses: 290),
  _Template(id: 't9', name: 'Wedding Highlights', duration: '1:00', category: 'Wedding', icon: Icons.favorite_rounded, color: PopCutColors.error, uses: 5400),
  _Template(id: 't10', name: 'Engagement Reel', duration: '0:30', category: 'Wedding', icon: Icons.diamond_rounded, color: PopCutColors.warning, uses: 870, isPro: true),
  _Template(id: 't11', name: 'Travel Vlog', duration: '0:20', category: 'Travel', icon: Icons.flight_takeoff_rounded, color: PopCutColors.primary, uses: 2100),
  _Template(id: 't12', name: 'Destination Reel', duration: '0:15', category: 'Travel', icon: Icons.terrain_rounded, color: PopCutColors.success, uses: 760),
  _Template(id: 't13', name: 'Tutorial Intro', duration: '0:08', category: 'Education', icon: Icons.school_rounded, color: PopCutColors.secondary, uses: 670),
  _Template(id: 't14', name: 'Course Preview', duration: '0:30', category: 'Education', icon: Icons.menu_book_rounded, color: PopCutColors.warning, uses: 230, isPro: true),
];
