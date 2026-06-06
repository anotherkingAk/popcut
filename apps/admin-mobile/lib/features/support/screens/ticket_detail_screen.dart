import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: Text('Ticket ${widget.ticketId}')),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('Issue Title', style: AppTypography.headlineSmall.copyWith(color: AdminColors.textPrimary))),
                    StatusBadge.fromString('open'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('user@example.com', style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
                    const SizedBox(width: 12),
                    Text(Formatters.timeAgo(DateTime.now().subtract(const Duration(hours: 5))), style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
                  ]),
                  const SizedBox(height: 12),
                  Text('I am experiencing an issue with the video export feature. The export keeps failing with an error message about insufficient storage.', style: AppTypography.bodyMedium.copyWith(color: AdminColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AdminColors.surfaceHover, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Support Agent', style: AppTypography.titleSmall.copyWith(color: AdminColors.primary)),
                    const Spacer(),
                    Text(Formatters.timeAgo(DateTime.now().subtract(const Duration(hours: 3))), style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
                  ]),
                  const SizedBox(height: 8),
                  Text('Thank you for reporting. We are looking into this issue. Could you please provide your device model and app version?', style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
                ]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AdminColors.border))),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a reply...',
                    hintStyle: const TextStyle(color: AdminColors.textMuted),
                    filled: true, fillColor: AdminColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AdminColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AdminColors.border)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(color: AdminColors.primary, shape: BoxShape.circle),
                child: IconButton(icon: const Icon(Icons.send, size: 16, color: Colors.white), onPressed: () {}),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
