import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/upload');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: SettingsHelper.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade600,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "تسجيل الدخول",
              style: SettingsHelper.getTextStyle(context,
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: settings.isDarkMode 
                        ? Colors.grey.shade700.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.lock_open,
                      size: 80,
                      color: settings.isDarkMode 
                        ? Colors.white
                        : Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    style: SettingsHelper.getTextStyle(context),
                    decoration: InputDecoration(
                      labelText: "البريد الإلكتروني",
                      labelStyle: SettingsHelper.getTextStyle(context,
                        color: settings.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: settings.isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: settings.isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: SettingsHelper.getCardColor(context),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: SettingsHelper.getTextStyle(context),
                    decoration: InputDecoration(
                      labelText: "كلمة المرور",
                      labelStyle: SettingsHelper.getTextStyle(context,
                        color: settings.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: settings.isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: settings.isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: SettingsHelper.getCardColor(context),
                    ),
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "تسجيل الدخول",
                      style: SettingsHelper.getTextStyle(context,
                        color: Colors.white,
                        sizeMultiplier: 1.1,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
