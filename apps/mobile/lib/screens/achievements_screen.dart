import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class AchievementsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AchievementsScreen({super.key, required this.onBack});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _streakDays = 7;
  final double _dailyGoalProgress = 0.65;
  final int _currentLevel = 12;
  final double _xpProgress = 0.72;
  final int _totalXp = 4850;
  final int _xpForNextLevel = 1500;

  final _achievements = List.generate(8, (i) => Achievement(
    title: 'Achievement ${i + 1}',
    description: 'Complete ${(i + 1) * 5} projects',
    icon: [Icons.videocam, Icons.star, Icons.timer, Icons.music_note, Icons.speed, Icons.auto_awesome, Icons.share, Icons.edit][i],
    unlocked: i < 4,
    progress: i < 4 ? 1.0 : (i - 3) * 0.15,
    xpReward: (i + 1) * 100,
  ));

  final _badges = List.generate(12, (i) => BadgeData(
    title: 'Badge ${i + 1}',
    tier: [BadgeTier.bronze, BadgeTier.silver, BadgeTier.gold, BadgeTier.platinum][i % 4],
    unlocked: i < 7,
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
        title: const Text('Achievements'),
      ),
      body: Column(
        children: [
          _buildStreakHeader(),
          _buildXpBar(),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.brand500,
            labelColor: AppColors.brand500,
            unselectedLabelColor: AppColors.textLow,
            tabs: const [
              Tab(text: 'Achievements'),
              Tab(text: 'Streaks'),
              Tab(text: 'Stats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievements(),
                _buildStreaks(),
                _buildStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('\u{1F525}', style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_streakDays Day Streak!', style: AppTypography.displaySm),
                const SizedBox(height: 4),
                Text('Keep creating every day', style: AppTypography.bodyMd),
              ],
            ),
          ),
          _buildDailyRing(),
        ],
      ),
    );
  }

  Widget _buildDailyRing() {
    return SizedBox(
      width: 52, height: 52,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: _dailyGoalProgress,
            strokeWidth: 4,
            backgroundColor: AppColors.bgOverlay,
            valueColor: const AlwaysStoppedAnimation(AppColors.brand500),
          ),
          Center(
            child: Text('${(_dailyGoalProgress * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBar() {
    final levelXp = _totalXp % _xpForNextLevel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level $_currentLevel', style: AppTypography.titleSm),
                Text('$_totalXp XP', style: AppTypography.bodySm),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _xpProgress,
                minHeight: 6,
                backgroundColor: AppColors.bgOverlay,
                valueColor: const AlwaysStoppedAnimation(AppColors.brand500),
              ),
            ),
            const SizedBox(height: 4),
            Text('$levelXp / $_xpForNextLevel XP to Level ${_currentLevel + 1}',
                style: AppTypography.bodySm),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _achievements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = _achievements[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: a.unlocked ? AppColors.brand500.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: a.unlocked ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(a.icon, color: a.unlocked ? AppColors.brand500 : AppColors.textLow, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(a.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: a.unlocked ? Colors.white : AppColors.textLow)),
                        const Spacer(),
                        Text('+${a.xpReward} XP', style: TextStyle(fontSize: 10, color: a.unlocked ? AppColors.brand500 : AppColors.textLow)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(a.description, style: AppTypography.bodyMd),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: a.progress,
                        minHeight: 4,
                        backgroundColor: AppColors.bgOverlay,
                        valueColor: AlwaysStoppedAnimation(a.unlocked ? AppColors.brand500 : AppColors.textLow),
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

  Widget _buildStreaks() {
    final milestones = [3, 7, 14, 30, 60, 90];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: milestones.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final milestone = milestones[i];
        final reached = _streakDays >= milestone;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: reached ? AppColors.brand500.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: Row(
            children: [
              Text(reached ? '\u{2728}' : '\u{23F3}', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$milestone-Day Streak',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: reached ? Colors.white : AppColors.textLow)),
                    const SizedBox(height: 2),
                    Text(reached ? 'Achieved!' : '${milestone - _streakDays} more days to go', style: AppTypography.bodyMd),
                  ],
                ),
              ),
              if (reached)
                const Icon(Icons.check_circle, color: AppColors.brand500, size: 20)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${milestone - _streakDays}d', style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _badges.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final b = _badges[i];
          return _BadgeCard(badge: b);
        },
      ),
    );
  }

  Widget _buildStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBadgeGrid(),
          const SizedBox(height: 16),
          _statCard(Icons.movie_creation_outlined, 'Total Projects', '47'),
          const SizedBox(height: 10),
          _statCard(Icons.file_upload_outlined, 'Total Exports', '32'),
          const SizedBox(height: 10),
          _statCard(Icons.timer_outlined, 'Total Edit Time', '128h 34m'),
          const SizedBox(height: 10),
          _statCard(Icons.favorite_outline, 'Favorite Tool', 'Trim Tool'),
          const SizedBox(height: 10),
          _statCard(Icons.local_fire_department, 'Longest Streak', '14 days'),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMedium, size: 22),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.bodyMd),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final double progress;
  final int xpReward;
  Achievement({required this.title, required this.description, required this.icon, required this.unlocked, required this.progress, required this.xpReward});
}

enum BadgeTier { bronze, silver, gold, platinum }

class BadgeData {
  final String title;
  final BadgeTier tier;
  final bool unlocked;
  BadgeData({required this.title, required this.tier, required this.unlocked});
}

class _BadgeCard extends StatelessWidget {
  final BadgeData badge;
  const _BadgeCard({required this.badge});

  Color _tierColor() {
    return switch (badge.tier) {
      BadgeTier.bronze => const Color(0xFFCD7F32),
      BadgeTier.silver => const Color(0xFFC0C0C0),
      BadgeTier.gold => const Color(0xFFFFD700),
      BadgeTier.platinum => const Color(0xFFE5E4E2),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _tierColor();
    final isPlatinum = badge.tier == BadgeTier.platinum;
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); },
      child: Container(
        decoration: BoxDecoration(
          color: badge.unlocked
              ? (isPlatinum
                  ? color.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.1))
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.unlocked ? color.withValues(alpha: 0.4) : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (badge.unlocked && isPlatinum)
              _shimmerEffect(child: Icon(Icons.auto_awesome, color: color, size: 28))
            else
              Icon(
                badge.unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: badge.unlocked ? color : AppColors.textLow,
                size: 28,
              ),
            const SizedBox(height: 6),
            Text(badge.title, style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: badge.unlocked ? color : AppColors.textLow,
            ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _shimmerEffect({required Widget child}) {
    return child;
  }
}
