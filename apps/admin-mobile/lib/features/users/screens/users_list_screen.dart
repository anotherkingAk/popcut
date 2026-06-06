import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/search_field.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/users_provider.dart';
import '../models/user_model.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(usersProvider.notifier).fetchUsers(refresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(usersProvider);
      if (!state.isLoadingMore && state.hasMore) {
        ref.read(usersProvider.notifier).fetchUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Users'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: SearchField(controller: _searchController, onChanged: (v) => ref.read(usersProvider.notifier).searchUsers(v))),
        Expanded(child: _buildList(state)),
      ]),
    );
  }

  Widget _buildList(UsersState state) {
    if (state.isLoading && state.users.isEmpty) return const Center(child: CircularProgressIndicator());
    if (state.error != null && state.users.isEmpty) return AppErrorWidget(message: state.error!, onRetry: () => ref.read(usersProvider.notifier).fetchUsers(refresh: true));
    if (state.users.isEmpty) return const EmptyState(icon: Icons.group, title: 'No users found');

    return RefreshIndicator(
      onRefresh: () => ref.read(usersProvider.notifier).fetchUsers(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.users.length + (state.hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= state.users.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
          return _UserTile(user: state.users[i], onTap: () => context.go('${AppRoutes.users}/${state.users[i].id}'));
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AdminColors.primary.withValues(alpha: 0.15),
              child: Text(user.initials, style: const TextStyle(color: AdminColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.displayName, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                const SizedBox(height: 2),
                Text(user.email, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
              ]),
            ),
            const SizedBox(width: 8),
            StatusBadge.fromString(user.status),
            const SizedBox(width: 8),
            Text(Formatters.compactNumber(user.projectsCount), style: AppTypography.labelLarge.copyWith(color: AdminColors.textMuted)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: AdminColors.textMuted),
          ]),
        ),
      ),
    );
  }
}
