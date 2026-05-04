import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isMobile => screenWidth < 768;

  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;

  bool get isDesktop => screenWidth >= 1024;

  EdgeInsets get padding => mediaQuery.padding;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  bool get isKeyboardOpen => viewInsets.bottom > 0;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}
