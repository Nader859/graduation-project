import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class ContactUsPage extends StatelessWidget {
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'تعذر فتح الرابط: $url';
    }
  }

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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "تواصل معنا",
              style: SettingsHelper.getTextStyle(
                context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                sizeMultiplier: 1.1,
              ),
            ),
            centerTitle: true,
            actions: [
              SettingsWidget(),
              SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ListView(
              children: [
                Text(
                  "يسرّنا تواصلك معنا عبر القنوات التالية:",
                  style: SettingsHelper.getTextStyle(
                    context,
                    fontWeight: FontWeight.bold,
                    sizeMultiplier: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildContactCard(
                    context,
                    FontAwesomeIcons.envelope,
                    "البريد الإلكتروني",
                    "mailto:contact@medscanapp.com",
                    Colors.orange),
                SizedBox(height: 15),
                _buildContactCard(context, FontAwesomeIcons.phone,
                    "اتصال هاتفي", "tel:+966501234567", Colors.teal),
                SizedBox(height: 15),
                _buildContactCard(context, FontAwesomeIcons.whatsapp, "واتساب",
                    "https://wa.me/966501234567", Colors.green),
                SizedBox(height: 15),
                _buildContactCard(context, FontAwesomeIcons.telegram,
                    "تيليجرام", "https://t.me/medscanapp", Colors.blueAccent),
                SizedBox(height: 15),
                _buildContactCard(context, FontAwesomeIcons.facebook, "فيسبوك",
                    "https://www.facebook.com/medscanapp", Colors.blue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title,
      String url, Color color) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(15),
      splashColor: color.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: SettingsHelper.getCardColor(context),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 15),
            Text(
              title,
              style: SettingsHelper.getTextStyle(
                context,
                fontWeight: FontWeight.w500,
                sizeMultiplier: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
