import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get mediaSize => MediaQuery.of(this).size;
  double get width => mediaSize.width;
  double get height => mediaSize.height;
  bool get isWide => width > 600;
  bool get isTablet => width > 768;
  bool get isDesktop => width > 1024;
  NavigatorState get navigator => Navigator.of(this);
  FocusScopeNode get focusScope => FocusScope.of(this);

  void showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFEF4444) : null,
      ),
    );
  }

  void showError(String message) => showSnackBar(message, error: true);

  void pop<T extends Object?>([T? result]) => navigator.pop(result);
}

extension WidgetRefExtensions on WidgetRef {
  void showSnackBar(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFEF4444) : null,
      ),
    );
  }
}
