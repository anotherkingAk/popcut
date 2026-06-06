import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/validators.dart';
import '../providers/notifications_provider.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(notificationsProvider.notifier).broadcast(
      _titleController.text.trim(),
      _bodyController.text.trim(),
    );
    if (success && mounted) {
      _titleController.clear();
      _bodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Broadcast'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Send Notification', style: AppTypography.headlineMedium.copyWith(color: AdminColors.textPrimary)),
            const SizedBox(height: 8),
            Text('This will be sent to all users', style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AdminColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Title', hintText: 'Notification title'),
              validator: (v) => Validators.required(v, 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              maxLines: 5,
              style: const TextStyle(color: AdminColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Message', hintText: 'Notification body', alignLabelWithHint: true),
              validator: (v) => Validators.required(v, 'Message'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _send, child: const Text('Send Broadcast')),
          ]),
        ),
      ),
    );
  }
}
