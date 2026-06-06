import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _numberFormat = NumberFormat.compact();
  static final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  static final _currencyFullFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy HH:mm');
  static final _shortDateFormat = DateFormat('MM/dd');
  static final _timeFormat = DateFormat('HH:mm');

  static String compactNumber(int n) => _numberFormat.format(n);
  static String compactCurrency(double n) => n >= 1000000 ? '\$${(n / 1000000).toStringAsFixed(1)}M' : n >= 1000 ? '\$${(n / 1000).toStringAsFixed(1)}K' : '\$${n.toStringAsFixed(0)}';
  static String currency(double n) => _currencyFormat.format(n);
  static String currencyFull(double n) => _currencyFullFormat.format(n);
  static String date(DateTime d) => _dateFormat.format(d);
  static String dateTime(DateTime d) => _dateTimeFormat.format(d);
  static String shortDate(DateTime d) => _shortDateFormat.format(d);
  static String time(DateTime d) => _timeFormat.format(d);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return Formatters.date(dt);
  }

  static String duration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  static String percentage(double v) => '${v.toStringAsFixed(1)}%';
  static String fileSize(int bytes) {
    if (bytes >= 1073741824) return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
