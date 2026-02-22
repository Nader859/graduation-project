import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../Settings_Page_Enhanced.dart';

class SettingsWidget extends StatelessWidget {
  final bool showAsFloatingButton;
  final Color? iconColor;
  final double? iconSize;

  const SettingsWidget({
    Key? key,
    this.showAsFloatingButton = false,
    this.iconColor,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (showAsFloatingButton) {
          return FloatingActionButton(
            mini: true,
            backgroundColor: settings.isDarkMode ? Colors.grey.shade700 : Colors.blue,
            onPressed: () => _openSettings(context),
            child: Icon(
              Icons.settings,
              color: Colors.white,
              size: iconSize,
            ),
          );
        }

        return IconButton(
          icon: Icon(
            Icons.settings,
            color: iconColor ?? (settings.isDarkMode ? Colors.white : Colors.black),
            size: iconSize,
          ),
          onPressed: () => _openSettings(context),
          tooltip: 'الإعدادات',
        );
      },
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPageEnhanced(),
      ),
    );
  }
}

// Quick settings overlay widget
class QuickSettingsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إعدادات سريعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickToggle(
                    context,
                    settings,
                    Icons.dark_mode,
                    'الوضع الداكن',
                    settings.isDarkMode,
                    settings.setDarkMode,
                  ),
                  _buildQuickToggle(
                    context,
                    settings,
                    Icons.notifications,
                    'الإشعارات',
                    settings.notificationsEnabled,
                    settings.setNotificationsEnabled,
                  ),
                  _buildQuickToggle(
                    context,
                    settings,
                    Icons.volume_up,
                    'الصوت',
                    settings.soundEnabled,
                    settings.setSoundEnabled,
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPageEnhanced()),
                  );
                },
                child: Text('المزيد من الإعدادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickToggle(
    BuildContext context,
    SettingsProvider settings,
    IconData icon,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: settings.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

// Settings overlay helper
class SettingsOverlay {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: QuickSettingsOverlay(),
      ),
    );
  }
}
