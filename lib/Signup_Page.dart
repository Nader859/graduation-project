import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Upload_Page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // 2. تهيئة Firestore
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 3. دالة مساعدة لحفظ بيانات المستخدم في Firestore
  Future<void> _saveUserData(User user, String name) async {
    // نستخدم .set مع merge:true لإنشاء المستند إذا لم يكن موجوداً، أو دمجه إذا كان موجوداً (مفيد لتسجيل جوجل)
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(), // تاريخ إنشاء الحساب
      'uid': user.uid,
    }, SetOptions(merge: true));
  }

  void _signUp() async {
    setState(() => _isLoading = true);
    try {
      // 4. الحصول على بيانات المستخدم بعد إنشاء الحساب
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // 5. حفظ بيانات المستخدم في Firestore
        await _saveUserData(user, _nameController.text.trim());

        // الانتقال للصفحة التالية بعد نجاح كل شيء
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UploadPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: ${e.toString()}")),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // المستخدم ألغى العملية

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 6. حفظ بيانات مستخدم جوجل في Firestore
        await _saveUserData(user, user.displayName ?? "مستخدم جوجل");

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UploadPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول بواسطة Google")),
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
              "إنشاء حساب جديد",
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: settings.isDarkMode 
                                ? Colors.grey.shade700.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.2),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Icon(
                              Icons.person_add,
                              size: 80,
                              color: settings.isDarkMode 
                                ? Colors.white
                                : Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _nameController,
                            style: SettingsHelper.getTextStyle(context),
                            decoration: InputDecoration(
                              labelText: "الاسم الكامل",
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
                              prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                              filled: true,
                              fillColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
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
                              fillColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
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
                              fillColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.white,
                            ),
                          ),
                          SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "إنشاء حساب",
                                    style: SettingsHelper.getTextStyle(context,
                                      color: Colors.white,
                                      sizeMultiplier: 1.1,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 15),
                          OutlinedButton(
                            onPressed: _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue.shade600),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.google,
                                    color: Colors.blue.shade600),
                                SizedBox(width: 10),
                                Text(
                                  "التسجيل بواسطة Google",
                                  style: SettingsHelper.getTextStyle(context,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
