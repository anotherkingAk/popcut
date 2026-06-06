import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ai_job_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/status_badge.dart';

class ApprovalsScreen extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const ApprovalsScreen({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchApprovals(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Approvals'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AdminColors.primary,
          labelColor: AdminColors.primary,
          unselectedLabelColor: AdminColors.textMedium,
          tabs: const [
            Tab(text: 'Content'),
            Tab(text: 'Tickets'),
          ],
        ),
      ),
      drawer: DrawerWidget(
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ContentApprovalsTab(),
          _TicketsTab(),
        ],
      ),
    );
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
          _item(Icons.group, 'Users', '/users'),
          _item(Icons.checklist, 'Approvals', '/approvals',
              selected: true),
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

class _ContentApprovalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        if (dp.isLoadingApprovals && dp.approvals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final content = dp.approvals.where((a) => a.type != 'ticket').toList();

        if (content.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    size: 48, color: AdminColors.success),
                const SizedBox(height: 12),
                const Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: 15,
                    color: AdminColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No pending content approvals',
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.textLow,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: content.length,
          itemBuilder: (_, i) => _ApprovalCard(item: content[i]),
        );
      },
    );
  }
}

class _TicketsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        if (dp.isLoadingApprovals && dp.approvals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = dp.approvals.where((a) => a.type == 'ticket').toList();

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_number,
                    size: 48, color: AdminColors.textLow),
                const SizedBox(height: 12),
                const Text(
                  'No open tickets',
                  style: TextStyle(
                    fontSize: 15,
                    color: AdminColors.textMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (_, i) => _ApprovalCard(item: tickets[i]),
        );
      },
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final ApprovalItem item;

  const _ApprovalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.type == 'ticket'
                      ? Icons.confirmation_number
                      : Icons.content_paste,
                  size: 16,
                  color: item.isPending
                      ? AdminColors.warning
                      : item.isApproved
                          ? AdminColors.success
                          : AdminColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AdminColors.textHigh,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'by ${item.submittedBy}  •  ${item.timeAgo}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdminColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.fromStatus(item.status),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AdminColors.textLow,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (item.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardProvider>()
                          .rejectItem(item.id);
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Reject',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.error,
                      side: BorderSide(
                          color: AdminColors.error.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardProvider>()
                          .approveItem(item.id);
                    },
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Approve',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
