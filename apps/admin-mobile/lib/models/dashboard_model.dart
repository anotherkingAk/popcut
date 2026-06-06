class DashboardStats {
  final int totalUsers;
  final int activeToday;
  final int newUsersToday;
  final double revenueToday;
  final double revenueThisMonth;
  final double revenueThisYear;
  final int activeJobs;
  final int exportsToday;
  final int exportsThisMonth;
  final int pendingApprovals;
  final int openTickets;
  final double dau;
  final double mau;
  final double serverUptime;
  final double apiErrorRate;
  final double avgResponseTime;

  DashboardStats({
    this.totalUsers = 0,
    this.activeToday = 0,
    this.newUsersToday = 0,
    this.revenueToday = 0,
    this.revenueThisMonth = 0,
    this.revenueThisYear = 0,
    this.activeJobs = 0,
    this.exportsToday = 0,
    this.exportsThisMonth = 0,
    this.pendingApprovals = 0,
    this.openTickets = 0,
    this.dau = 0,
    this.mau = 0,
    this.serverUptime = 100,
    this.apiErrorRate = 0,
    this.avgResponseTime = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeToday: json['activeToday'] as int? ?? 0,
      newUsersToday: json['newUsersToday'] as int? ?? 0,
      revenueToday: (json['revenueToday'] as num?)?.toDouble() ?? 0,
      revenueThisMonth: (json['revenueThisMonth'] as num?)?.toDouble() ?? 0,
      revenueThisYear: (json['revenueThisYear'] as num?)?.toDouble() ?? 0,
      activeJobs: json['activeJobs'] as int? ?? 0,
      exportsToday: json['exportsToday'] as int? ?? 0,
      exportsThisMonth: json['exportsThisMonth'] as int? ?? 0,
      pendingApprovals: json['pendingApprovals'] as int? ?? 0,
      openTickets: json['openTickets'] as int? ?? 0,
      dau: (json['dau'] as num?)?.toDouble() ?? 0,
      mau: (json['mau'] as num?)?.toDouble() ?? 0,
      serverUptime: (json['serverUptime'] as num?)?.toDouble() ?? 100,
      apiErrorRate: (json['apiErrorRate'] as num?)?.toDouble() ?? 0,
      avgResponseTime: (json['avgResponseTime'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RevenuePoint {
  final DateTime date;
  final double amount;

  RevenuePoint({required this.date, required this.amount});

  factory RevenuePoint.fromJson(Map<String, dynamic> json) {
    return RevenuePoint(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class ActivityPoint {
  final DateTime date;
  final int count;

  ActivityPoint({required this.date, required this.count});

  factory ActivityPoint.fromJson(Map<String, dynamic> json) {
    return ActivityPoint(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int,
    );
  }
}

class ChartData {
  final List<RevenuePoint> revenueHistory;
  final List<ActivityPoint> dauHistory;
  final List<ActivityPoint> mauHistory;
  final List<ActivityPoint> signupsHistory;

  ChartData({
    this.revenueHistory = const [],
    this.dauHistory = const [],
    this.mauHistory = const [],
    this.signupsHistory = const [],
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      revenueHistory: (json['revenueHistory'] as List<dynamic>?)
              ?.map((e) => RevenuePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dauHistory: (json['dauHistory'] as List<dynamic>?)
              ?.map((e) => ActivityPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mauHistory: (json['mauHistory'] as List<dynamic>?)
              ?.map((e) => ActivityPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      signupsHistory: (json['signupsHistory'] as List<dynamic>?)
              ?.map((e) => ActivityPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
