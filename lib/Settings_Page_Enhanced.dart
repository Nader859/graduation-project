import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/settings_provider.dart';

class SettingsPageEnhanced extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor:
              settings.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: settings.isDarkMode
                ? Colors.grey.shade800
                : Colors.blue.shade600,
            title: Text(
              "الإعدادات",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Profile Section
              _buildProfileSection(settings),
              SizedBox(height: 24),

              // Appearance Settings
              _buildSectionHeader("المظهر", Icons.palette, settings),
              _buildSettingCard(
                settings,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      settings,
                      "الوضع الداكن",
                      "تفعيل المظهر الداكن للتطبيق",
                      Icons.dark_mode,
                      settings.isDarkMode,
                      settings.setDarkMode,
                    ),
                    Divider(height: 1),
                    _buildSliderTile(
                      settings,
                      "حجم الخط",
                      "تعديل حجم النص في التطبيق",
                      Icons.text_fields,
                      settings.fontSize,
                      12.0,
                      24.0,
                      settings.setFontSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Notifications Settings
              _buildSectionHeader("الإشعارات", Icons.notifications, settings),
              _buildSettingCard(
                settings,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      settings,
                      "تشغيل الإشعارات",
                      "استقبال إشعارات التطبيق",
                      Icons.notifications,
                      settings.notificationsEnabled,
                      settings.setNotificationsEnabled,
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      settings,
                      "الأصوات",
                      "تشغيل أصوات الإشعارات",
                      Icons.volume_up,
                      settings.soundEnabled,
                      settings.setSoundEnabled,
                    ),
                    Divider(height: 1),
                    _buildSwitchTile(
                      settings,
                      "الاهتزاز",
                      "تفعيل الاهتزاز مع الإشعارات",
                      Icons.vibration,
                      settings.vibrationEnabled,
                      settings.setVibrationEnabled,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Privacy Settings
              _buildSectionHeader("الخصوصية", Icons.security, settings),
              _buildSettingCard(
                settings,
                child: _buildSwitchTile(
                  settings,
                  "مشاركة الموقع",
                  "السماح للتطبيق بالوصول للموقع",
                  Icons.location_on,
                  settings.locationAccess,
                  settings.setLocationAccess,
                ),
              ),

              SizedBox(height: 16),

              // Language Settings
              _buildSectionHeader("اللغة", Icons.language, settings),
              _buildSettingCard(
                settings,
                child: _buildLanguageTile(settings, context),
              ),

              SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(settings, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(SettingsProvider settings) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              size: 35,
              color: Colors.blue.shade600,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المستخدم",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: settings.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "user@example.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: settings.isDarkMode
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit,
            color: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, SettingsProvider settings) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: settings.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(SettingsProvider settings, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile(
    SettingsProvider settings,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: settings.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: settings.isDarkMode ? Colors.white70 : Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildSliderTile(
    SettingsProvider settings,
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: settings.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color:
                  settings.isDarkMode ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 2).round(),
            label: value.round().toString(),
            onChanged: onChanged,
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(SettingsProvider settings, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language,
          color: Colors.blue.shade600,
          size: 20,
        ),
      ),
      title: Text(
        "اختيار اللغة",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: settings.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        settings.selectedLanguage,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: settings.isDarkMode ? Colors.white54 : Colors.grey.shade400,
      ),
      onTap: () => _showLanguageDialog(context, settings),
    );
  }

  Widget _buildActionButtons(SettingsProvider settings, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showResetDialog(context, settings),
            icon: Icon(Icons.refresh),
            label: Text("إعادة تعيين الإعدادات"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: Icon(Icons.logout),
            label: Text("تسجيل الخروج"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "اختر اللغة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            ...settings.languages
                .map((lang) => ListTile(
                      title: Text(
                        lang,
                        style: TextStyle(
                          color:
                              settings.isDarkMode ? Colors.white : Colors.black,
                          fontWeight: settings.selectedLanguage == lang
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: settings.selectedLanguage == lang
                          ? Icon(Icons.check, color: Colors.blue.shade600)
                          : null,
                      onTap: () {
                        settings.setSelectedLanguage(lang);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("إعادة تعيين الإعدادات"),
        content: Text(
            "هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم إعادة تعيين الإعدادات بنجاح")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text("إعادة تعيين"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تسجيل الخروج"),
        content: Text("هل أنت متأكد من تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to login page or home page
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم تسجيل الخروج بنجاح")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("حدث خطأ في تسجيل الخروج")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("تسجيل الخروج"),
          ),
        ],
      ),
    );
  }
}
