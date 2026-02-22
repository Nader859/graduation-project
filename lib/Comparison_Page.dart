// lib/comparison_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class ComparisonPage extends StatefulWidget {
  final List<DocumentSnapshot> analyses;

  const ComparisonPage({Key? key, required this.analyses}) : super(key: key);

  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  bool _isLoading = true;
  String? _comparisonResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchComparison();
  }

  Future<void> _fetchComparison() async {
    final List<String> texts = widget.analyses
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['analysisResult'] as String)
        .toList();

    const String compareUrl =
        "https://graduation-project-tqlv.onrender.com/compare";

    try {
      final response = await http
          .post(
            Uri.parse(compareUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"analysesTexts": texts}),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _comparisonResult = data['comparison'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load comparison: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = "حدث خطأ أثناء الحصول على المقارنة: $e";
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(BuildContext context) {
    if (_comparisonResult != null) {
      Clipboard.setData(ClipboardData(text: _comparisonResult!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ نتيجة المقارنة!')),
      );
    }
  }

  Future<void> _saveAsPdf(BuildContext context) async {
    final pdf = pw.Document();
    final fontData =
        await rootBundle.load("assets/google_fonts/NotoKufiArabic-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final String cleanText =
        _comparisonResult?.replaceAll('**', '').replaceAll('#', '').trim() ??
            '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("نتيجة مقارنة التحاليل",
                    style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text(cleanText,
                    style: pw.TextStyle(fontSize: 14, lineSpacing: 5)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
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
            title: Text(
              "نتيجة المقارنة",
              style: SettingsHelper.getTextStyle(
                context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                sizeMultiplier: 1.1,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (_comparisonResult != null &&
                  !_isLoading &&
                  _error == null) ...[
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  tooltip: 'نسخ النتيجة',
                  onPressed: () => _copyToClipboard(context),
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  tooltip: 'حفظ كـ PDF',
                  onPressed: () => _saveAsPdf(context),
                ),
              ],
              const SettingsWidget(),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final comparisonResult = _comparisonResult; // نسخة محلية

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (_isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue.shade600),
                const SizedBox(height: 20),
                Text(
                  "جاري تحليل المقارنة...",
                  style:
                      SettingsHelper.getTextStyle(context, sizeMultiplier: 1.1),
                ),
              ],
            ),
          );
        }

        if (_error != null) {
          return Center(
            child: Text(
              _error!,
              style: SettingsHelper.getTextStyle(context, color: Colors.red),
            ),
          );
        }

        if (comparisonResult != null) {
          return Column(
            children: [
              Expanded(
                child: Markdown(
                  data: comparisonResult,
                  styleSheet: MarkdownStyleSheet(
                    p: SettingsHelper.getTextStyle(context, height: 1.5),
                    h1: SettingsHelper.getTextStyle(context,
                        sizeMultiplier: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600),
                    h2: SettingsHelper.getTextStyle(context,
                        sizeMultiplier: 1.3,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600),
                    h3: SettingsHelper.getTextStyle(context,
                        sizeMultiplier: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600),
                    strong: SettingsHelper.getTextStyle(context,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ النتيجة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => _copyToClipboard(context),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('حفظ كـ PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => _saveAsPdf(context),
                  ),
                ],
              ),
            ],
          );
        }

        return Center(
          child: Text(
            "لا توجد بيانات لعرضها.",
            style: SettingsHelper.getTextStyle(context),
          ),
        );
      },
    );
  }
}
