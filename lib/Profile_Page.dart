import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'analysis_detail_page.dart';
import 'Comparison_Page.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_widget.dart';
import 'utils/settings_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Set<DocumentSnapshot> _selectedAnalyses = {};
  bool _selectionMode = false;

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
              "الملف الشخصي",
              style: SettingsHelper.getTextStyle(context,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  sizeMultiplier: 1.2),
            ),
            actions: [
              if (_selectionMode) ...[
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: _deleteSelectedAnalyses,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectionMode = false;
                      _selectedAnalyses.clear();
                    });
                  },
                ),
                SizedBox(width: 8),
              ] else ...[
                SettingsWidget(),
                SizedBox(width: 8),
              ],
            ],
          ),
          floatingActionButton: _selectionMode && _selectedAnalyses.length >= 2
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonPage(
                          analyses: _selectedAnalyses.toList(),
                        ),
                      ),
                    );
                  },
                  label: Text("مقارنة (${_selectedAnalyses.length})"),
                  icon: Icon(Icons.compare_arrows),
                )
              : null,
          body: user == null
              ? Center(
                  child: Text(
                    "الرجاء تسجيل الدخول لعرض الملف الشخصي",
                    style: SettingsHelper.getTextStyle(context),
                  ),
                )
              : Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: settings.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: settings.isDarkMode
                            ? Colors.white
                            : Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      user?.displayName ?? user?.email ?? "اسم المستخدم",
                      style: SettingsHelper.getTextStyle(context,
                          fontWeight: FontWeight.bold, sizeMultiplier: 1.3),
                    ),
                    Text(
                      user?.email ?? "لا يوجد بريد إلكتروني",
                      style: SettingsHelper.getTextStyle(context,
                          color: settings.isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade600),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "سجل التحاليل (اختر 2 أو أكثر للمقارنة)",
                          style: SettingsHelper.getTextStyle(context,
                              fontWeight: FontWeight.bold, sizeMultiplier: 1.2),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _buildAnalysesHistory(user!, settings),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAnalysesHistory(User user, SettingsProvider settings) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "لا توجد تحاليل محفوظة بعد.",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ في جلب البيانات"));
        }

        final analyses = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: analyses.length,
          itemBuilder: (context, index) {
            final analysisDoc = analyses[index];
            final data = analysisDoc.data() as Map<String, dynamic>;
            final result =
                data['analysisResult']?.toString() ?? 'لا توجد نتيجة';
            final timestamp = data['timestamp'] as Timestamp?;
            final formattedDate = timestamp != null
                ? DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp.toDate())
                : 'تاريخ غير معروف';

            final bool isSelected = _selectedAnalyses.contains(analysisDoc);

            return GestureDetector(
              onLongPress: () {
                setState(() {
                  _selectionMode = true;
                  _selectedAnalyses.add(analysisDoc);
                });
              },
              onTap: () {
                if (_selectionMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedAnalyses.remove(analysisDoc);
                      if (_selectedAnalyses.isEmpty) {
                        _selectionMode = false;
                      }
                    } else {
                      _selectedAnalyses.add(analysisDoc);
                    }
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisDetailPage(
                        analysisResult: result,
                        date: formattedDate, // ✅ هذا هو الصحيح
                      ),
                    ),
                  );
                }
              },
              child: Card(
                elevation: isSelected ? 4 : 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isSelected
                      ? BorderSide(color: Colors.blue, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  tileColor: isSelected
                      ? (settings.isDarkMode
                          ? Colors.blue.shade800.withOpacity(0.3)
                          : Colors.blue.shade50)
                      : null,
                  leading: _selectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedAnalyses.add(analysisDoc);
                              } else {
                                _selectedAnalyses.remove(analysisDoc);
                                if (_selectedAnalyses.isEmpty) {
                                  _selectionMode = false;
                                }
                              }
                            });
                          },
                        )
                      : Icon(
                          Icons.receipt_long,
                          color: settings.isDarkMode
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                  title: Text(
                    "تحليل بتاريخ: $formattedDate",
                    style: SettingsHelper.getTextStyle(context,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    result.length > 50
                        ? result.substring(0, 50) + '...'
                        : result,
                    maxLines: 2,
                    style: SettingsHelper.getTextStyle(context,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade600),
                  ),
                  trailing: !_selectionMode
                      ? Icon(Icons.arrow_forward_ios, size: 16)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteSelectedAnalyses() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد أنك تريد حذف التحاليل المحددة؟"),
        actions: [
          TextButton(
            child: Text("إلغاء"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("حذف"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (var doc in _selectedAnalyses) {
        await doc.reference.delete();
      }
      setState(() {
        _selectedAnalyses.clear();
        _selectionMode = false;
      });
    }
  }
}
