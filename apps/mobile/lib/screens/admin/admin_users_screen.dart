import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminUsersScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AdminUsersScreen({super.key, required this.onBack});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int? _expandedIndex;

  final _filters = ['All', 'Active', 'Banned', 'Suspended'];

  @override
  void dispose() {
    _searchController.dispose();
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
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
            },
          ),
        ],
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
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textHigh, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(color: AppColors.textLow),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textLow),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) => setState(() {}),
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
            onTap: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _selectedFilter = _filters[i]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brand500 : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.brand500 : AppColors.border,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final user = _users[i];
        final isExpanded = _expandedIndex == i;
        final isSearchMatch = _searchController.text.isEmpty ||
            user.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchController.text.toLowerCase());
        if (!isSearchMatch) return const SizedBox.shrink();

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.brand500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.brand500),
                        ),
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                        Text('Joined ${user.joinDate}  •  Last active ${user.lastActive}', style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _statusBadge(user.status),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: AppColors.textLow,
                          ),
                          onPressed: () {
                            HapticService.trigger(HapticLevel.light);
                            setState(() => _expandedIndex = isExpanded ? null : i);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    onTap: () {
                      HapticService.trigger(HapticLevel.light);
                      setState(() => _expandedIndex = isExpanded ? null : i);
                    },
                    dense: true,
                  ),
                  if (isExpanded) _buildExpandedPanel(user),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedPanel(_AdminUser user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              _detailChip('Projects', '${user.projects}'),
              const SizedBox(width: 8),
              _detailChip('Storage', user.storage),
              const SizedBox(width: 8),
              _detailChip('Plan', user.plan),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('View', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textHigh,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.warning_amber_outlined, size: 14),
                  label: const Text('Warn', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.medium);
                  },
                  icon: const Icon(Icons.block_outlined, size: 14),
                  label: Text(
                    user.status == 'Banned' ? 'Unban' : 'Ban',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color color;
    switch (status) {
      case 'Active':
        color = AppColors.success;
      case 'Banned':
        color = AppColors.error;
      case 'Suspended':
        color = AppColors.warning;
      default:
        color = AppColors.textLow;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
      ),
    );
  }
}

class _AdminUser {
  final String name;
  final String email;
  final String status;
  final String joinDate;
  final String lastActive;
  final int projects;
  final String storage;
  final String plan;

  const _AdminUser({
    required this.name,
    required this.email,
    required this.status,
    required this.joinDate,
    required this.lastActive,
    required this.projects,
    required this.storage,
    required this.plan,
  });
}

const _users = <_AdminUser>[
  _AdminUser(name: 'Alice Johnson', email: 'alice@example.com', status: 'Active', joinDate: 'Jan 2025', lastActive: '2 min ago', projects: 12, storage: '2.3 GB', plan: 'Pro'),
  _AdminUser(name: 'Bob Smith', email: 'bob@example.com', status: 'Active', joinDate: 'Mar 2025', lastActive: '1h ago', projects: 5, storage: '0.8 GB', plan: 'Free'),
  _AdminUser(name: 'Charlie Brown', email: 'charlie@example.com', status: 'Banned', joinDate: 'Dec 2024', lastActive: '3 days ago', projects: 8, storage: '1.5 GB', plan: 'Free'),
  _AdminUser(name: 'Diana Ross', email: 'diana@example.com', status: 'Active', joinDate: 'Feb 2025', lastActive: '5 min ago', projects: 25, storage: '4.7 GB', plan: 'Pro'),
  _AdminUser(name: 'Eve Wilson', email: 'eve@example.com', status: 'Suspended', joinDate: 'Apr 2025', lastActive: '2 days ago', projects: 3, storage: '0.2 GB', plan: 'Free'),
  _AdminUser(name: 'Frank Miller', email: 'frank@example.com', status: 'Active', joinDate: 'Jun 2025', lastActive: '30 min ago', projects: 18, storage: '3.1 GB', plan: 'Pro'),
  _AdminUser(name: 'Grace Lee', email: 'grace@example.com', status: 'Active', joinDate: 'Jul 2025', lastActive: 'Just now', projects: 7, storage: '1.2 GB', plan: 'Free'),
  _AdminUser(name: 'Henry Davis', email: 'henry@example.com', status: 'Banned', joinDate: 'Oct 2024', lastActive: '1 week ago', projects: 2, storage: '0.1 GB', plan: 'Free'),
];
