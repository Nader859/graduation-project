import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Helper class for common settings-related operations
class SettingsHelper {
  
  /// Get the current theme colors based on settings
  static ColorScheme getColorScheme(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settings.isDarkMode) {
      return ColorScheme.dark(
        primary: Colors.blue.shade400,
        secondary: Colors.blue.shade300,
        surface: Colors.grey.shade800,
        background: Colors.grey.shade900,
      );
    } else {
      return ColorScheme.light(
        primary: Colors.blue.shade600,
        secondary: Colors.blue.shade400,
        surface: Colors.white,
        background: Colors.grey.shade50,
      );
    }
  }

  /// Get text style with current font size settings
  static TextStyle getTextStyle(BuildContext context, {
    FontWeight? fontWeight,
    Color? color,
    double? sizeMultiplier = 1.0,
    double? height,
  }) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return TextStyle(
      fontSize: settings.fontSize * (sizeMultiplier ?? 1.0),
      fontWeight: fontWeight,
      color: color ?? (settings.isDarkMode ? Colors.white : Colors.black),
    );
  }

  /// Get background color based on current theme
  static Color getBackgroundColor(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return settings.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
  }

  /// Get card color based on current theme
  static Color getCardColor(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return settings.isDarkMode ? Colors.grey.shade800 : Colors.white;
  }

  /// Get primary color based on current theme
  static Color getPrimaryColor(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return settings.isDarkMode ? Colors.blue.shade400 : Colors.blue.shade600;
  }

  /// Show settings-aware snackbar
  static void showSnackBar(BuildContext context, String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: settings.fontSize - 2),
        ),
        backgroundColor: settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade800,
        action: action,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Create settings-aware dialog
  static Future<T?> showSettingsDialog<T>(
    BuildContext context, {
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : Colors.black,
            fontSize: settings.fontSize + 2,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: settings.fontSize,
          ),
        ),
        actions: actions,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Get app bar theme based on settings
  static AppBarTheme getAppBarTheme(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return AppBarTheme(
      backgroundColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: settings.fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Create settings-aware elevated button
  static ElevatedButton createButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(
          fontSize: settings.fontSize,
          color: textColor ?? Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? getPrimaryColor(context),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
