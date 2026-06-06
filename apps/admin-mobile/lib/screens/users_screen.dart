import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/user_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/status_badge.dart';

class UsersScreen extends StatefulWidget {
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;
  final String currentRoute;

  const UsersScreen({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedFilter = 'All';

  final _filters = ['All', 'Active', 'Suspended', 'Banned'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchUsers(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DashboardProvider>().fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Users'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerWidget(
        currentRoute: widget.currentRoute,
        onNavigate: (route) => widget.onNavigate(route),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AdminColors.textHigh, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(color: AdminColors.textLow),
          prefixIcon:
              Icon(Icons.search, size: 18, color: AdminColors.textLow),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (v) {
          context.read<DashboardProvider>().searchUsers(v);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = _filters[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminColors.primary
                    : AdminColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AdminColors.primary : AdminColors.border,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AdminColors.textHigh
                      : AdminColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        if (dp.isLoadingUsers && dp.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = dp.users.where((u) {
          if (_selectedFilter == 'All') return true;
          return u.status.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off,
                    size: 48, color: AdminColors.textLow),
                const SizedBox(height: 12),
                const Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AdminColors.textMedium,
                  ),
                ),
                if (dp.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dp.error!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length + (dp.hasMoreUsers ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= filtered.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return _UserCard(
              user: filtered[i],
              onTap: () => widget.onNavigate('/user-detail',
                  args: {'userId': filtered[i].id}),
              onSuspend: () => _handleSuspend(filtered[i]),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSuspend(AdminUser user) async {
    final dp = context.read<DashboardProvider>();
    if (user.isSuspended) {
      await dp.unsuspendUser(user.id);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AdminColors.surface,
          title: const Text(
            'Suspend User',
            style: TextStyle(color: AdminColors.textHigh),
          ),
          content: Text(
            'Are you sure you want to suspend ${user.displayName}?',
            style: const TextStyle(color: AdminColors.textMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error,
              ),
              child: const Text('Suspend'),
            ),
          ],
        ),
      );
      if (confirm == true && mounted) {
        await dp.suspendUser(user.id);
      }
    }
  }
}

class DrawerWidget extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const DrawerWidget({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AdminColors.primaryDim, AdminColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.admin_panel_settings,
                    size: 32, color: Colors.white),
                SizedBox(height: 12),
                Text('PopCut Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Control your ecosystem',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _item(Icons.dashboard, 'Dashboard', '/dashboard'),
          _item(Icons.group, 'Users', '/users', selected: true),
          _item(Icons.checklist, 'Approvals', '/approvals'),
          _item(Icons.auto_awesome, 'AI Factory', '/ai-factory'),
          _item(Icons.notifications, 'Notifications', '/notifications'),
          _item(Icons.analytics, 'Analytics', '/analytics'),
          _item(Icons.settings, 'Settings', '/settings'),
        ],
      ),
    );
  }

  ListTile _item(IconData icon, String label, String route,
      {bool selected = false}) {
    return ListTile(
      leading: Icon(icon,
          size: 20,
          color: selected ? AdminColors.primary : AdminColors.textMedium),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              color:
                  selected ? AdminColors.primary : AdminColors.textHigh)),
      onTap: () => onNavigate(route),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;
  final VoidCallback onSuspend;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: user.isPro
                ? AdminColors.primary.withValues(alpha: 0.2)
                : AdminColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              user.initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    user.isPro ? AdminColors.primary : AdminColors.textMedium,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.textHigh,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StatusBadge.fromStatus(user.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 12,
                color: AdminColors.textMedium,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${user.projectsCount} projects  •  ${user.plan.toUpperCase()}',
              style: const TextStyle(
                fontSize: 10,
                color: AdminColors.textLow,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: AdminColors.textLow),
          color: AdminColors.surfaceElevated,
          onSelected: (v) {
            if (v == 'suspend') onSuspend();
            if (v == 'view') onTap();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility_outlined,
                    size: 18, color: AdminColors.textMedium),
                title: Text('View Details',
                    style: TextStyle(fontSize: 13)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'suspend',
              child: ListTile(
                leading: Icon(
                  user.isSuspended
                      ? Icons.check_circle_outline
                      : Icons.block_outlined,
                  size: 18,
                  color: user.isSuspended
                      ? AdminColors.success
                      : AdminColors.error,
                ),
                title: Text(
                  user.isSuspended ? 'Unsuspend' : 'Suspend',
                  style: const TextStyle(fontSize: 13),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
