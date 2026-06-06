abstract final class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
    return null;
  }

  static String? Function(String?) minLength(int min) => (String? v) {
    if (v == null || v.length < min) return 'Minimum $min characters';
    return null;
  };

  static String? Function(String?) maxLength(int max) => (String? v) {
    if (v != null && v.length > max) return 'Maximum $max characters';
    return null;
  };
}
