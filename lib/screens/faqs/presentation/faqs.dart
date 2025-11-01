import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';

// Simple model for FAQ data
class FaqItem {
  final String id;
  final String question;
  final String answer;

  FaqItem({required this.id, required this.question, required this.answer});
}

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  // --- Mock Data ---
  final List<FaqItem> _faqs = [
    FaqItem(
      id: '1',
      question: 'كيف يمكنني الاطلاع على الجدول الدراسي؟',
      answer:
          'يمكنك العثور على جدولك الدراسي الكامل في قسم "الجدول الدراسي" من القائمة الرئيسية للتطبيق. يتم تحديث الجدول بانتظام.',
    ),
    FaqItem(
      id: '2',
      question: 'ماذا أفعل إذا نسيت كلمة المرور؟',
      answer:
          'في شاشة تسجيل الدخول، اضغط على رابط "هل نسيت كلمة السر؟" واتبع التعليمات لإعادة تعيين كلمة المرور الخاصة بك عبر البريد الإلكتروني المسجل.',
    ),
    FaqItem(
      id: '3',
      question: 'كيف أتواصل مع معلم المادة؟',
      answer:
          'يمكنك التواصل مباشرة مع معلميك من خلال قسم "المحادثات" في التطبيق. ابحث عن اسم المعلم لبدء محادثة جديدة.',
    ),
    FaqItem(
      id: '4',
      question: 'أين أجد المواد الدراسية والملفات المرفوعة؟',
      answer:
          'جميع الملفات والمواد المتعلقة بالحصص الدراسية متاحة في قسم "الملفات الدراسية". يمكنك تصفيتها حسب المادة.',
    ),
    // Add more FAQs here...
  ];

  // --- Controller for the new question field ---
  final _newQuestionController = TextEditingController();

  @override
  void dispose() {
    _newQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // disables the back button
        forceMaterialTransparency: true,
        // --- End Shadowless AppBar ---
        centerTitle: true,
        title: const Text(
          'الأسئلة الشائعة',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. List of FAQs
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return _FaqTile(faq: faq);
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: dividerColor, height: 1, thickness: 1),
            ),
          ),

          // 2. Section to send a new question
          _buildSendQuestionSection(),
        ],
      ),
    );
  }

  Widget _buildSendQuestionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: screenBg,
        border: const Border(top: BorderSide(color: dividerColor)),
        boxShadow: [
          BoxShadow(
            color: iconGrey.withAlpha((0.1 * 255).round()),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2), // Shadow upwards
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Take minimum space needed
        children: [
          const Text(
            'لم تجد إجابتك؟ أرسل سؤالك للإدارة:',
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newQuestionController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    filled: true,
                    fillColor: textFieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: screenBg,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_outlined),
                onPressed: _sendQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendQuestion() {
    final question = _newQuestionController.text.trim();
    if (question.isNotEmpty) {
      // TODO: Implement sending logic (e.g., save to Firestore, show confirmation)
      log('Sending question: $question');
      _newQuestionController.clear();
      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال سؤالك بنجاح ✅'),
          backgroundColor: primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء كتابة سؤال قبل الإرسال'),
          backgroundColor: offlineIndicator,
        ),
      );
    }
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }
}

// --- FAQ Expansion Tile Widget ---
class _FaqTile extends StatelessWidget {
  final FaqItem faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // Customize expansion tile appearance
      tilePadding: const EdgeInsets.symmetric(vertical: 8.0),
      childrenPadding: const EdgeInsets.only(
        bottom: 16.0,
        right: 16.0,
        left: 16.0,
      ),
      iconColor: primaryGreen,
      collapsedIconColor: iconGrey,
      shape: const Border(), // Remove default border
      collapsedShape: const Border(), // Remove default border when collapsed

      title: Text(
        faq.question,
        style: const TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600, // Slightly bolder than answer
          fontSize: 16,
        ),
      ),
      children: [
        Text(
          faq.answer,
          style: const TextStyle(
            color: secondaryText,
            fontSize: 14,
            height: 1.5, // Line spacing
          ),
        ),
      ],
    );
  }
}
