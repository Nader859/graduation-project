import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'Signup_Page.dart';
import 'Login_Page.dart';
import 'Upload_Page.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // للتطوير فقط - إزالة في الإنتاج
  if (kDebugMode) {
    // <-- يعمل الآن بعد الاستيراد
    HttpOverrides.global = MyHttpOverrides();
  }

  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'التطبيق الطبي',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Tajawal',
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: settings.fontSize),
              bodyMedium: TextStyle(fontSize: settings.fontSize - 2),
            ),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: settings.fontSize),
              bodyMedium: TextStyle(fontSize: settings.fontSize - 2),
            ),
          ),
          themeMode: settings.themeMode,
          home: HomePage(),
          routes: {
            '/signup': (context) => SignupPage(),
            '/login': (context) => LoginPage(),
            '/upload': (context) => UploadPage(),
          },
        );
      },
    );
  }
}

//#HF_TOKEN=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
