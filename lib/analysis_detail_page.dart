// lib/analysis_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class AnalysisDetailPage extends StatelessWidget {
  final String analysisResult;
  final String date;

  const AnalysisDetailPage({
    Key? key,
    required this.analysisResult,
    required this.date,
  }) : super(key: key);

  // --- دوال التحكم بالأزرار ---

  // 1. وظيفة النسخ
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: analysisResult));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ التحليل إلى الحافظة!')),
    );
  }

  // 2. وظيفة المشاركة
  void _shareAnalysis() {
    Share.share(analysisResult, subject: 'نتيجة تحليل طبي');
  }

// استبدل دالة _saveAsPdf القديمة بهذه
  Future<void> _saveAsPdf() async {
    final pdf = pw.Document();

    // ▼▼▼ هذا هو التعديل: ننظف النص أولاً قبل استخدامه ▼▼▼
    final String cleanAnalysisResult = _cleanTextForPdf(analysisResult);

    // تحميل الخط العربي
    final fontData =
        await rootBundle.load("assets/google_fonts/NotoKufiArabic-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

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
                pw.Text("تقرير تحليل طبي", style: pw.TextStyle(fontSize: 24)),
                pw.Text("تاريخ التحليل: $date",
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Divider(height: 20),
                // ▼▼▼ نستخدم النص النظيف هنا ▼▼▼
                pw.Text(cleanAnalysisResult,
                    style: const pw.TextStyle(fontSize: 14, lineSpacing: 5)),
              ],
            ),
          );
        },
      ),
    );

    // طباعة وحفظ الـ PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

// دالة لتنظيف النص من رموز الماركدوان
  String _cleanTextForPdf(String markdownText) {
    // إزالة رموز الخط العريض (النجمتين)
    String text = markdownText.replaceAll('**', '');
    // إزالة رموز العناوين (#)
    text = text.replaceAll(RegExp(r'^\s*#+\s*', multiLine: true), '');
    // إزالة رموز القوائم النقطية (* or -)
    text = text.replaceAll(RegExp(r'^\s*[\*\-]\s*', multiLine: true), '');
    // إزالة أي مسافات زائدة قد تنتج
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: SettingsHelper.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: settings.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade600,
            title: Text(
              'تفاصيل التحليل',
              style: SettingsHelper.getTextStyle(context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                sizeMultiplier: 1.1,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
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
                // --- قسم عرض التحليل ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: SettingsHelper.getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: settings.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        analysisResult,
                        style: SettingsHelper.getTextStyle(context, height: 1.5),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),

                Divider(
                  height: 30,
                  color: settings.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                ),

                // --- قسم أزرار التحكم ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(context,
                          icon: Icons.copy,
                          label: "نسخ",
                          onPressed: () => _copyToClipboard(context)),
                      _buildActionButton(context,
                          icon: Icons.share,
                          label: "مشاركة",
                          onPressed: _shareAnalysis),
                      _buildActionButton(context,
                          icon: Icons.save_alt,
                          label: "حفظ",
                          onPressed: _saveAsPdf),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              icon: Icon(icon),
              onPressed: onPressed,
              iconSize: 30,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: SettingsHelper.getTextStyle(context),
            ),
          ],
        );
      },
    );
  }
}
