extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  String get initials {
    final parts = split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (isNotEmpty) return this[0].toUpperCase();
    return '?';
  }

  String ellipsis(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  String toSnakeCase() => replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)}').toLowerCase().replaceAll(RegExp(r'^_'), '');

  String toKebabCase() => toSnakeCase().replaceAll('_', '-');
}
