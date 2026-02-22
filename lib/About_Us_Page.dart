import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class AboutUsPage extends StatelessWidget {
  final List<Map<String, String>> teamMembers = [
    {
      "name": "م. نادر منصور",
      "phone": "775336217",
      "email": "nadermansour859@gmail.com",
      "role": "مبرمج ومطور النظام",
    },
    {
      "name": "م.عبدالحق خالد",
      "phone": "776158990",
      "email": "formystudy911313@gmail.com",
      "role": "مهندس برمجيات",
    },
    {
      "name": "م. رهيب حمادي",
      "phone": "774113738",
      "email": "raheebalwajeeh@gmail.com",
      "role": "مصمم واجهات وتجربة مستخدم",
    },
    {
      "name": "م. محمد عبدالغفار",
      "phone": "774 439 429",
      "email": "alhodalimohammed65@gmail.com",
      "role": "مختبر جودة وضمان",
    },
    {
      "name": "م. حسين صادق",
      "phone": "773307341",
      "email": "hytfg777@gmail.com",
      "role": "إدارة المحتوى والدعم الفني",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: SettingsHelper.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: settings.isDarkMode
                ? Colors.grey.shade800
                : Colors.blue.shade600,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "من نحن",
              style: SettingsHelper.getTextStyle(
                context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                sizeMultiplier: 1.1,
              ),
            ),
            actions: [
              SettingsWidget(),
              SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تعرف على فريق تطوير التطبيق",
                  style: SettingsHelper.getTextStyle(
                    context,
                    fontWeight: FontWeight.bold,
                    sizeMultiplier: 1.2,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: SettingsHelper.getCardColor(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: settings.isDarkMode
                                ? Colors.grey.shade600
                                : Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: settings.isDarkMode
                                  ? Colors.white
                                  : Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            teamMembers[index]["name"]!,
                            style: SettingsHelper.getTextStyle(
                              context,
                              fontWeight: FontWeight.bold,
                              sizeMultiplier: 1.1,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.work,
                                      color: Colors.blue.shade700, size: 18),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      teamMembers[index]["role"]!,
                                      style: SettingsHelper.getTextStyle(
                                        context,
                                        color: settings.isDarkMode
                                            ? Colors.white70
                                            : Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      color: Colors.blue.shade700, size: 18),
                                  SizedBox(width: 5),
                                  Text(
                                    teamMembers[index]["phone"]!,
                                    style: SettingsHelper.getTextStyle(
                                      context,
                                      color: settings.isDarkMode
                                          ? Colors.white70
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.email,
                                      color: Colors.blue.shade700, size: 18),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      teamMembers[index]["email"]!,
                                      style: SettingsHelper.getTextStyle(
                                        context,
                                        color: settings.isDarkMode
                                            ? Colors.white70
                                            : Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
