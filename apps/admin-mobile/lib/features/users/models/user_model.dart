class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String status;
  final String plan;
  final int projectsCount;
  final double storageUsed;
  final double storageLimit;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool emailVerified;
  final List<String> roles;

  AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.status = 'active',
    this.plan = 'free',
    this.projectsCount = 0,
    this.storageUsed = 0,
    this.storageLimit = 1.0,
    required this.createdAt,
    required this.lastActive,
    this.emailVerified = false,
    this.roles = const [],
  });

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isBanned => status == 'banned';
  bool get isPro => plan != 'free';

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['display_name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      status: json['status'] as String? ?? 'active',
      plan: json['plan'] as String? ?? json['subscription'] as String? ?? 'free',
      projectsCount: json['projectsCount'] as int? ?? json['project_count'] as int? ?? 0,
      storageUsed: (json['storageUsed'] as num?)?.toDouble() ?? 0,
      storageLimit: (json['storageLimit'] as num?)?.toDouble() ?? 1.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive'] as String) : DateTime.now(),
      emailVerified: json['emailVerified'] as bool? ?? json['isVerified'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class PaginatedUsers {
  final List<AdminUser> users;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  PaginatedUsers({required this.users, required this.total, required this.page, required this.limit, required this.hasMore});

  factory PaginatedUsers.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final usersList = (data['users'] as List<dynamic>?)?.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    return PaginatedUsers(users: usersList, total: data['total'] as int? ?? usersList.length, page: data['page'] as int? ?? 1, limit: data['limit'] as int? ?? 20, hasMore: data['hasMore'] as bool? ?? false);
  }
}
