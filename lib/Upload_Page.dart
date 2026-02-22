import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'profile_page.dart';
import 'About_Us_Page.dart';
import 'Contact_Us_Page.dart';
import 'Settings_Page_Enhanced.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تحليل طبي',
      debugShowCheckedModeBanner: false, // إزالة شريط التصحيح
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue.shade700,
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade700,
          secondary: Colors.green.shade600, // لون ثانوي طبي
          surface: Colors.white,
          background: Colors
              .blue.shade50, // الخلفية الزرقاء الشفافة كما في الكود الأصلي
          error: Colors.red.shade700,
        ),
        fontFamily: 'NotoKufiArabic',
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade900,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade800,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue.shade50, // نفس لون الخلفية الأصلي
          iconTheme: IconThemeData(color: Colors.blue.shade900),
          titleTextStyle: TextStyle(
            color: Colors.blue.shade900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoKufiArabic',
          ),
        ),
      ),
      home: UploadPage(),
    );
  }
}

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ... باقي المتغيرات الخاصة بك
  File? _image;
  String _analysisResult = "";
  String _extractedText = "";
  bool _isLoading = false;
  final picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  List<String> _processingSteps = [];
  final ScrollController _scrollController = ScrollController();
  final translator = GoogleTranslator();

  // إضافة متغيرات للرسوم المتحركة
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _processAndAnalyze() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _processingSteps.clear();
      _analysisResult = "";
      _extractedText = "";
    });

    try {
      _addProcessingStep("جاري معالجة الصورة...");

      final inputImage = InputImage.fromFilePath(_image!.path);
      _addProcessingStep("جاري استخراج النص...");
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        throw Exception("لم يتم العثور على نص");
      }

      _addProcessingStep("جاري تنظيف النص...");
      final cleanedText = _cleanText(recognizedText.text);

      setState(() {
        _extractedText = cleanedText;
        _processingSteps.add("✅ اكتمل استخراج النص");
      });
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _cleanText(String text) {
    return text
        // حذف جميع الرموز غير العربية/الإنجليزية/الرقمية
        .replaceAll(
            RegExp(r'[^\u060012860m-\u07FF\u0350-\u077Fa-zA-Z0-9°µ%±→↑↓،٫\s]'),
            ' ')
        // إزالة الفراغات الزائدة
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  Future<void> _sendForAnalysis() async {
    if (_extractedText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _processingSteps.add("جاري التحليل...");
    });

    const String renderUrl =
        "https://graduation-project-tqlv.onrender.com/analyze";

    // --- بداية كود التشخيص ---
    print("--- بدء عملية الإرسال ---");
    print("سيتم إرسال الطلب إلى الرابط التالي: $renderUrl");
    // --- نهاية كود التشخيص ---

    try {
      final response = await http
          .post(
            Uri.parse(renderUrl),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "text": _extractedText,
            }),
          )
          .timeout(const Duration(seconds: 90));

      // --- بداية كود التشخيص ---
      print("تم استلام الرد من الخادم بنجاح.");
      print("رمز الحالة (Status Code): ${response.statusCode}");
      print("محتوى الرد (Body): ${response.body}");
      // --- نهاية كود التشخيص ---

      _handleResponse(response);
    } catch (e) {
      // --- بداية كود التشخيص ---
      print("!!!!!!!! حدث خطأ فادح أثناء محاولة إرسال الطلب !!!!!!!!");
      print("نوع الخطأ: ${e.runtimeType}");
      print("رسالة الخطأ الكاملة: $e");
      // --- نهاية كود التشخيص ---
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      _handleSuccess(response.body);
    } else {
      final errorMessage = response.statusCode == 503
          ? "النموذج قيد التحميل، يرجى المحاولة مرة أخرى لاحقًا"
          : "خطأ في واجهة برمجة التطبيقات (${response.statusCode})";

      final errorBody = response.body;
      final maxLength = errorBody.length < 100 ? errorBody.length : 100;

      throw Exception("$errorMessage: ${errorBody.substring(0, maxLength)}");
    }
  }

  // هذه الدالة موجودة لديك بالفعل، سنقوم فقط بإضافة كود الحفظ بداخلها
  Future<void> _handleSuccess(String response) async {
    try {
      final jsonResponse = jsonDecode(response);
      String result = jsonResponse["analysis"] ?? "No analysis found";

      // الترجمة إلى العربية إذا كانت النتيجة بالإنجليزية
      if (_isEnglish(result)) {
        result = await _translateToArabic(result);
      }

      final formattedResult = _formatMedicalResponse(result); // النتيجة المنسقة

      setState(() {
        _analysisResult = formattedResult;
        _addProcessingStep("✅ نجح التحليل");
      });

      // ▼▼▼▼▼ الكود الجديد الذي سنضيفه لحفظ التحليل ▼▼▼▼▼
      try {
        // 1. الحصول على المستخدم الحالي الذي سجل دخوله
        final User? user = _auth.currentUser;

        // 2. التأكد من وجود مستخدم مسجل دخوله
        if (user != null) {
          // 3. إضافة مستند جديد في مجموعة التحاليل الخاصة به
          await _firestore
              .collection('users') // اذهب إلى مجموعة المستخدمين
              .doc(user.uid) // اختر المستخدم الحالي
              .collection('analyses') // اذهب إلى مجموعته الفرعية للتحاليل
              .add({
            // أضف مستنداً جديداً بالبيانات التالية
            'analysisResult':
                formattedResult, // نتيجة التحليل من الذكاء الاصطناعي
            'extractedText': _extractedText, // النص الأصلي المستخرج من الصورة
            'timestamp': FieldValue.serverTimestamp(), // تاريخ ووقت الحفظ
          });

          print("تم حفظ التحليل بنجاح في Firestore!");
          _addProcessingStep("✅ تم حفظ التحليل في ملفك الشخصي");
        }
      } catch (e) {
        print("حدث خطأ أثناء حفظ التحليل: $e");
        _addProcessingStep("❌ فشل حفظ التحليل");
      }
      // ▲▲▲▲▲ نهاية الكود الجديد ▲▲▲▲▲
    } catch (e) {
      _handleError(Exception("تنسيق الاستجابة غير صالح: ${e.toString()}"));
    }
  }

  Future<String> _translateToArabic(String text) async {
    try {
      final translated = await translator.translate(text, to: 'ar');
      return translated.text;
    } catch (e) {
      return text; // العودة للنص الأصلي في حالة الخطأ
    }
  }

  bool _isEnglish(String text) {
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  String _formatMedicalResponse(String response) {
    return response
        // حذف الرموز الخاصة والأحرف التالفة
        .replaceAll(
            RegExp(r'[^\u0600-\u06FF\u0750-\u077Fa-zA-Z0-9%\s،٫.:➤-]'), '')
        // تحسين التنسيق
        .replaceAllMapped(RegExp(r'(?<=\d)(\.|,)'), (m) => '.\n')
        .replaceAll('•', '➤')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        // ترجمة المصطلحات
        .replaceAllMapped(
            RegExp(r'\b(Vitamin|vitamin)\b', caseSensitive: false),
            (_) => 'فيتامين')
        .replaceAllMapped(
            RegExp(r'\b(Recommend|recommend)\b', caseSensitive: false),
            (_) => 'توصية');
  }

  void _handleError(dynamic error) {
    String errorMsg = error.toString();

    // إزالة "Exception: " من بداية الرسالة
    errorMsg = errorMsg.replaceAll('Exception: ', '');

    // تقصير الرسالة إذا كانت طويلة
    errorMsg =
        errorMsg.length > 200 ? errorMsg.substring(0, 200) + '...' : errorMsg;

    setState(() {
      _analysisResult = "⚠️ خطأ: $errorMsg";
      _addProcessingStep("❌ فشل: $errorMsg");
    });
  }

  void _addProcessingStep(String step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _processingSteps.add(step);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _processAndAnalyze();
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _processAndAnalyze();
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/Medscan(3).png'),
                ),
              ),
              Text(
                'القائمة الرئيسية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.person,
                        title: "الملف الشخصي",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ProfilePage())),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.info,
                        title: "من نحن",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AboutUsPage())),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.contact_mail,
                        title: "اتصل بنا",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ContactUsPage())),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings,
                        title: "الإعدادات",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SettingsPageEnhanced()));
                        },
                      ),
                      Divider(color: Colors.grey.shade300),
                      _buildDrawerItem(
                        context,
                        icon: Icons.help_outline,
                        title: "المساعدة",
                        onTap: () {
                          Navigator.pop(context);
                          _showHelpDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: Colors.blue.shade700),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'NotoKufiArabic',
              fontWeight: FontWeight.w500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue.shade700),
              SizedBox(width: 10),
              Text(
                "كيفية استخدام التطبيق",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpStep(
                  "1", "قم بتحميل صورة التقرير الطبي من خلال زر 'اختر صورة'"),
              SizedBox(height: 8),
              _buildHelpStep("2", "انتظر حتى يتم استخراج النص من الصورة"),
              SizedBox(height: 8),
              _buildHelpStep(
                  "3", "اضغط على زر 'ابدأ التحليل' للحصول على نتائج التحليل"),
              SizedBox(height: 8),
              _buildHelpStep("4", "اطلع على النتائج وحفظها إذا لزم الأمر"),
            ],
          ),
          actions: [
            TextButton(
              child:
                  Text("فهمت", style: TextStyle(color: Colors.blue.shade700)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.photo_library, color: Colors.blue.shade700),
              SizedBox(width: 10),
              Text(
                "اختر مصدر الصورة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageSourceOption(
                  context,
                  icon: Icons.camera_alt,
                  title: "التقاط صورة",
                  subtitle: "استخدام الكاميرا لالتقاط صورة جديدة",
                  onTap: () {
                    Navigator.pop(context);
                    _takePicture();
                  },
                ),
                SizedBox(height: 16),
                _buildImageSourceOption(
                  context,
                  icon: Icons.image,
                  title: "اختر من المعرض",
                  subtitle: "اختيار صورة موجودة من معرض الصور",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.blue.shade50, // الخلفية الزرقاء الشفافة كما في الكود الأصلي
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.blue.shade900),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              color: Colors.blue.shade900,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "تحليل طبي",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/Medscan(3).png'),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderSection(),
                SizedBox(height: 25),
                _buildImagePreviewSection(),
                SizedBox(height: 30),
                _buildUploadButtonSection(),
                if (_image != null) ...[
                  SizedBox(height: 30),
                  _buildProcessingInfoSection(),
                  SizedBox(height: 20),
                  _buildAnalyzeButtonSection(),
                  SizedBox(height: 30),
                  _buildResultDisplaySection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "قم بتحميل صورة التقرير الطبي",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "سيقوم النظام بتحليل التقرير واستخراج النتائج بشكل تلقائي",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description,
              color: Colors.blue.shade700,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "اضغط على زر 'اختر صورة' لتحميل صورة التقرير",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _image = null;
                            _extractedText = "";
                            _analysisResult = "";
                            _processingSteps.clear();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUploadButtonSection() {
    return ElevatedButton.icon(
      onPressed: _showImageSourceDialog,
      icon: Icon(Icons.upload_file, size: 24),
      label: Text(
        "اختر صورة",
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: Colors.blue.shade200,
      ),
    );
  }

  Widget _buildProcessingInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "سجل المعالجة:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: _processingSteps.isEmpty
                  ? Center(
                      child: Text(
                        "لا توجد خطوات معالجة بعد",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      itemCount: _processingSteps.length,
                      itemBuilder: (context, index) {
                        final step = _processingSteps[index];
                        final isSuccess = step.contains("✅");
                        final isError = step.contains("❌");

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSuccess
                                      ? Colors.green.withOpacity(0.1)
                                      : isError
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    isSuccess
                                        ? Icons.check
                                        : isError
                                            ? Icons.close
                                            : Icons.arrow_right,
                                    size: 14,
                                    color: isSuccess
                                        ? Colors.green
                                        : isError
                                            ? Colors.red
                                            : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step
                                      .replaceAll("✅ ", "")
                                      .replaceAll("❌ ", ""),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSuccess
                                        ? Colors.green
                                        : isError
                                            ? Colors.red
                                            : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButtonSection() {
    return ElevatedButton.icon(
      onPressed: _isLoading || _extractedText.isEmpty ? null : _sendForAnalysis,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(Icons.analytics, size: 24),
      label: Text(
        _isLoading ? "جاري التحليل..." : "ابدأ التحليل",
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: Colors.green.shade200,
      ),
    );
  }

  Widget _buildResultDisplaySection() {
    final hasError = _analysisResult.contains("⚠️");

    return AnimatedOpacity(
      opacity: _analysisResult.isEmpty ? 0.0 : 1.0,
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: hasError
                ? Colors.red.shade200
                : _analysisResult.isNotEmpty
                    ? Colors.green.shade200
                    : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    hasError ? Icons.error_outline : Icons.check_circle_outline,
                    color: hasError ? Colors.red : Colors.green,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "نتائج التحليل:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasError ? Colors.red : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasError
                      ? Colors.red.shade50
                      : Colors.blue.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasError
                    ? SelectableText(
                        _analysisResult,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                      )
                    : _analysisResult.isEmpty
                        ? Center(
                            child: Text(
                              "اضغط على زر 'ابدأ التحليل' للحصول على النتائج",
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : SelectableText(
                            _analysisResult,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.blue.shade900,
                              fontFamily: 'NotoKufiArabic',
                            ),
                            textDirection: TextDirection.rtl,
                          ),
              ),
              if (_analysisResult.isNotEmpty && !hasError) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: "نسخ",
                      onTap: () {
                        // تنفيذ عملية النسخ (يمكن استخدام حزمة clipboard)
                      },
                    ),
                    SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.share,
                      label: "مشاركة",
                      onTap: () {
                        // تنفيذ عملية المشاركة
                      },
                    ),
                    SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.save_alt,
                      label: "حفظ",
                      onTap: () {
                        // تنفيذ عملية الحفظ
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue.shade700,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}