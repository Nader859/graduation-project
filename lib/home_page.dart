import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: SettingsHelper.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              SettingsWidget(),
              SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: settings.isDarkMode
                          ? Colors.grey.shade700.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.all(20),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          AssetImage('assets/images/Medscan(3).png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "مرحبًا بك في تطبيق التحليل الطبي",
                    style: SettingsHelper.getTextStyle(
                      context,
                      sizeMultiplier: 1.4,
                      fontWeight: FontWeight.bold,
                      color: settings.isDarkMode
                          ? Colors.white
                          : Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "قم برفع صورة الفحص الطبي واحصل على توصيات مخصصة لصحتك.",
                    style: SettingsHelper.getTextStyle(
                      context,
                      sizeMultiplier: 1.0,
                      color: settings.isDarkMode
                          ? Colors.white70
                          : Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "إنشاء حساب",
                      style: SettingsHelper.getTextStyle(
                        context,
                        sizeMultiplier: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade600),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "تسجيل دخول",
                      style: SettingsHelper.getTextStyle(
                        context,
                        sizeMultiplier: 1.1,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: SettingsWidget(showAsFloatingButton: true),
        );
      },
    );
  }
}
