enum AiJobType { textToVideo, imageToVideo, videoEditing, audioGeneration, unknown }

enum AiJobStatus { pending, running, completed, failed, cancelled }

class AiJob {
  final String id;
  final String userId;
  final String? userEmail;
  final AiJobType type;
  final AiJobStatus status;
  final String? prompt;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int retryCount;
  final String? errorMessage;
  final Map<String, dynamic>? result;

  AiJob({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.type,
    required this.status,
    this.prompt,
    this.progress = 0,
    required this.createdAt,
    this.completedAt,
    this.retryCount = 0,
    this.errorMessage,
    this.result,
  });

  bool get isFailed => status == AiJobStatus.failed;
  bool get isRunning => status == AiJobStatus.running;
  bool get isCompleted => status == AiJobStatus.completed;
  bool get isRetryable => isFailed && retryCount < 3;

  String get typeLabel {
    switch (type) {
      case AiJobType.textToVideo:
        return 'Text to Video';
      case AiJobType.imageToVideo:
        return 'Image to Video';
      case AiJobType.videoEditing:
        return 'Video Editing';
      case AiJobType.audioGeneration:
        return 'Audio Generation';
      case AiJobType.unknown:
        return 'Unknown';
    }
  }

  String get statusLabel {
    switch (status) {
      case AiJobStatus.pending:
        return 'Pending';
      case AiJobStatus.running:
        return 'Running';
      case AiJobStatus.completed:
        return 'Completed';
      case AiJobStatus.failed:
        return 'Failed';
      case AiJobStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get duration {
    if (completedAt == null) return 'In progress';
    final diff = completedAt!.difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  factory AiJob.fromJson(Map<String, dynamic> json) {
    return AiJob(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? json['user_email'] as String?,
      type: _parseJobType(json['type'] as String? ?? ''),
      status: _parseJobStatus(json['status'] as String? ?? ''),
      prompt: json['prompt'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      createdAt: (json['createdAt'] as String?) != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: (json['completedAt'] as String?) != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String? ?? json['error'] as String?,
      result: json['result'] as Map<String, dynamic>?,
    );
  }

  static AiJobType _parseJobType(String type) {
    switch (type.toLowerCase()) {
      case 'text_to_video':
      case 'text-to-video':
        return AiJobType.textToVideo;
      case 'image_to_video':
      case 'image-to-video':
        return AiJobType.imageToVideo;
      case 'video_editing':
      case 'video-editing':
        return AiJobType.videoEditing;
      case 'audio_generation':
      case 'audio-generation':
        return AiJobType.audioGeneration;
      default:
        return AiJobType.unknown;
    }
  }

  static AiJobStatus _parseJobStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AiJobStatus.pending;
      case 'running':
      case 'processing':
        return AiJobStatus.running;
      case 'completed':
      case 'done':
        return AiJobStatus.completed;
      case 'failed':
      case 'error':
        return AiJobStatus.failed;
      case 'cancelled':
      case 'canceled':
        return AiJobStatus.cancelled;
      default:
        return AiJobStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'type': type.name,
      'status': status.name,
      'prompt': prompt,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'result': result,
    };
  }
}

class ApprovalItem {
  final String id;
  final String type;
  final String title;
  final String? description;
  final String submittedBy;
  final String? submittedByEmail;
  final DateTime submittedAt;
  final String status;
  final String? contentType;

  ApprovalItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.submittedBy,
    this.submittedByEmail,
    required this.submittedAt,
    this.status = 'pending',
    this.contentType,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get timeAgo {
    final diff = DateTime.now().difference(submittedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'content',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      submittedBy: json['submittedBy'] as String? ?? json['userName'] as String? ?? 'Unknown',
      submittedByEmail: json['submittedByEmail'] as String? ?? json['userEmail'] as String?,
      submittedAt: (json['submittedAt'] as String?) != null
          ? DateTime.parse(json['submittedAt'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      contentType: json['contentType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'submittedBy': submittedBy,
      'submittedByEmail': submittedByEmail,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'contentType': contentType,
    };
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'info',
    this.read = false,
    required this.createdAt,
    this.data,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      read: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: (json['createdAt'] as String?) != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }
}
