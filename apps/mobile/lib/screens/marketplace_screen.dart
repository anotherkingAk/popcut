import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class MarketplaceScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const MarketplaceScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _carouselCtl = PageController(viewportFraction: 0.9);
  Timer? _carouselTimer;
  int _carouselPage = 0;
  int _cartCount = 0;
  bool _showCart = false;
  int _selectedItemIndex = -1;

  final _tabs = ['For You', 'Templates', 'Transitions', 'Effects', 'Fonts', 'Soundtrack'];

  final _featured = List.generate(3, (i) => MarketplaceItem(
    title: 'Featured ${i + 1}',
    author: 'Creator ${i + 1}',
    price: i == 0 ? 0.0 : (i + 1) * 2.99,
    rating: 4.5 + i * 0.2,
    downloads: '${(i + 1) * 10}k',
    category: 'Template',
  ));

  final _gridItems = List.generate(12, (i) => MarketplaceItem(
    title: 'Item ${i + 1}',
    author: 'Creator ${(i % 5) + 1}',
    price: i % 3 == 0 ? 0.0 : (i % 5) * 1.99 + 0.99,
    rating: 4.0 + (i % 5) * 0.2,
    downloads: '${(i + 1) * 5}k',
    category: ['Template', 'Transition', 'Effect', 'Font', 'Soundtrack'][i % 5],
  ));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_carouselPage < 2) {
        _carouselCtl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        _carouselCtl.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselCtl.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _addToCart() {
    HapticService.trigger(HapticLevel.light);
    setState(() => _cartCount++);
  }

  @override
  Widget build(BuildContext context) {
    if (_showCart) return _buildCartScreen();
    if (_selectedItemIndex >= 0) return _buildItemDetail();
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); }),
        title: const Text('Marketplace'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showCart = true); },
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text('$_cartCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.brand500,
              labelColor: AppColors.brand500,
              unselectedLabelColor: AppColors.textLow,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((_) => _buildMarketplaceBody()).toList(),
      ),
    );
  }

  Widget _buildMarketplaceBody() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        _buildFeaturedCarousel(),
        const SizedBox(height: 16),
        _buildGrid(),
      ],
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _carouselCtl,
              onPageChanged: (p) { HapticService.trigger(HapticLevel.light); setState(() => _carouselPage = p); },
              itemCount: _featured.length,
              itemBuilder: (_, i) {
                final f = _featured[i];
                return GestureDetector(
                  onTap: () { HapticService.trigger(HapticLevel.light); setState(() => _selectedItemIndex = i); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: [AppColors.trackVideo, AppColors.trackAudio, AppColors.trackEffect][i % 3].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(f.title, style: AppTypography.displaySm),
                              const SizedBox(height: 4),
                              Text('by ${f.author}', style: AppTypography.bodyMd),
                              const SizedBox(height: 8),
                              _priceBadge(f.price),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_featured.length, (i) => Container(
              width: 6, height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _carouselPage == i ? AppColors.brand500 : AppColors.textLow,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _gridItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final item = _gridItems[i];
          return GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); setState(() => _selectedItemIndex = i); },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(_categoryIcon(item.category), size: 28, color: AppColors.textLow.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      CircleAvatar(radius: 7, backgroundColor: AppColors.bgOverlay, child: Text(item.author[0], style: const TextStyle(fontSize: 7, color: AppColors.textMedium))),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.author, style: AppTypography.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _priceBadge(item.price),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, size: 10, color: AppColors.warning),
                          Text(item.rating.toStringAsFixed(1), style: AppTypography.bodySm),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${item.downloads} downloads', style: AppTypography.bodySm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _priceBadge(double price) {
    if (price == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('Free', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildItemDetail() {
    final item = _selectedItemIndex < _featured.length && _selectedItemIndex < 3
        ? _featured[_selectedItemIndex]
        : _gridItems[_selectedItemIndex % _gridItems.length];
    final reviews = ['Great quality!', 'Very useful', 'Amazing effects', 'Worth it'];
    final related = _gridItems.where((x) => x.id != item.id).take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _selectedItemIndex = -1); }),
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showCart = true); },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: AppColors.bgElevated,
              child: Center(
                child: Icon(_categoryIcon(item.category), size: 48, color: AppColors.textLow.withValues(alpha: 0.3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.title, style: AppTypography.titleLg)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _priceBadge(item.price),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: AppColors.warning),
                              Text(item.rating.toStringAsFixed(1), style: AppTypography.bodySm),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('by ${item.author}', style: AppTypography.bodyMd),
                  const SizedBox(height: 4),
                  Text('${item.downloads} downloads', style: AppTypography.bodySm),
                  const SizedBox(height: 16),
                  Text('Description of ${item.title}. This is a high-quality ${item.category.toLowerCase()} for your video editing projects.',
                      style: AppTypography.bodyMd),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { HapticService.trigger(HapticLevel.light); if (item.price > 0) _addToCart(); },
                      child: Text(item.price == 0 ? 'Get' : 'Buy \$${item.price.toStringAsFixed(2)}'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Reviews', style: AppTypography.titleSm),
                  const SizedBox(height: 12),
                  for (final r in reviews) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: AppColors.warning)),
                          ),
                          const SizedBox(width: 8),
                          Text(r, style: AppTypography.bodyMd),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 24),
                  Text('Related Items', style: AppTypography.titleSm),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: related.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final r = related[i];
                        return GestureDetector(
                          onTap: () { HapticService.trigger(HapticLevel.light); },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgElevated,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(child: Icon(_categoryIcon(r.category), size: 20, color: AppColors.textLow.withValues(alpha: 0.4))),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(r.title, style: const TextStyle(fontSize: 11, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildCartScreen() {
    final cartItems = _gridItems.take(_cartCount).toList();
    final total = cartItems.fold(0.0, (s, i) => s + i.price);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showCart = false); }),
        title: const Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textLow.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: AppTypography.titleSm),
                  const SizedBox(height: 4),
                  Text('Browse the marketplace to add items', style: AppTypography.bodyMd),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final ci = cartItems[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
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
                                  Text(ci.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                                  Text(ci.author, style: AppTypography.bodySm),
                                ],
                              ),
                            ),
                            _priceBadge(ci.price),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppColors.textLow),
                              onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _cartCount--); },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${cartItems.length} item${cartItems.length != 1 ? 's' : ''}', style: AppTypography.bodySm),
                          Text('\$${total.toStringAsFixed(2)}', style: AppTypography.titleLg),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () { HapticService.trigger(HapticLevel.medium); },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Template' => Icons.movie_creation_outlined,
      'Transition' => Icons.swap_horiz,
      'Effect' => Icons.auto_awesome,
      'Font' => Icons.text_fields,
      'Soundtrack' => Icons.music_note_outlined,
      _ => Icons.folder_outlined,
    };
  }
}

class MarketplaceItem {
  static int _counter = 0;
  final int id;
  final String title;
  final String author;
  final double price;
  final double rating;
  final String downloads;
  final String category;

  MarketplaceItem({
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    required this.downloads,
    required this.category,
  }) : id = _counter++;
}
