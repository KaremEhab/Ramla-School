import 'dart:io'; // ✅ (الإضافة 1) لاستخدام File()
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/document_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Documents extends StatefulWidget {
  final List<DocumentModel> documentUrls;

  const Documents({super.key, required this.documentUrls});

  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color iconGrey = Color(0xFFAAAAAA);

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  String? _selectedSubject;
  bool _sortByRecent = true;
  late List<DocumentModel> _documents;

  // 👇 الصف الحالي كمثال
  final Grade currentGrade = Grade.grade6;

  @override
  void initState() {
    super.initState();
    _documents = List.from(widget.documentUrls);
  }

  List<DocumentModel> get _filteredDocuments {
    List<DocumentModel> filtered = _documents;
    if (_selectedSubject != null && _selectedSubject != 'الكل') {
      filtered = filtered
          .where((doc) => doc.subject == _selectedSubject)
          .toList();
    }
    filtered.sort(
      (a, b) => _sortByRecent
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return filtered;
  }

  List<String> get _subjects {
    final subjects = _documents.map((doc) => doc.subject).toSet().toList();
    subjects.insert(0, 'الكل');
    return subjects;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat arabicDateFormat = DateFormat('d/M/y', 'ar');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Documents.primaryGreen,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'الملفات الدراسية',
          style: TextStyle(
            color: Documents.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSortRow(),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredDocuments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          color: Colors.grey[400],
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد ملفات متاحة حالياً',
                          style: TextStyle(
                            color: Documents.secondaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'سيتم عرض الملفات هنا عند إضافتها',
                          style: TextStyle(
                            color: Documents.iconGrey,
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: _filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = _filteredDocuments[index];
                      return _DocumentCard(
                        document: document,
                        dateFormat: arabicDateFormat,
                      );
                    },
                  ),
          ),
        ],
      ),

      // ✅ (الإصلاح 3) تم تصحيح المنطق ليتطابق مع التعليق
      floatingActionButton: currentRole == UserRole.teacher
          ? FloatingActionButton(
              backgroundColor: Documents.primaryGreen,
              onPressed: _showAddDocumentSheet,
              shape: CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilterSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubject ?? 'الكل',
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Documents.iconGrey,
                ),
                style: const TextStyle(
                  color: Documents.primaryText,
                  fontFamily: 'Tajawal',
                ),
                items: _subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedSubject = newValue);
                },
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _sortByRecent = !_sortByRecent),
            child: Row(
              children: [
                Text(
                  _sortByRecent ? 'حديثاً' : 'قديماً',
                  style: const TextStyle(color: Documents.secondaryText),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.history, color: Documents.iconGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ (الإصلاح 1) تم حذف ميثود _requestFilePermission لأنها غير ضرورية وتسبب مشاكل

  void _showAddDocumentSheet() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String? selectedFilePath;
    SchoolSubject? selectedSubject;

    final availableSubjects =
        SchoolSubject.values
            .where((s) => s.isAvailableFor(currentGrade))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة ملف جديد',
                    style: TextStyle(
                      color: Documents.primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الملف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<SchoolSubject>(
                    value: selectedSubject,
                    items: availableSubjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name, textAlign: TextAlign.right),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setModalState(() => selectedSubject = value),
                    decoration: const InputDecoration(
                      labelText: 'اسم المادة',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      color: Documents.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الملف (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () async {
                      // ✅ (الإصلاح 1) تم حذف كود طلب الصلاحيات الخاطئ من هنا
                      // file_picker سيتعامل مع الصلاحيات بنفسه
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                      if (result != null && result.files.single.path != null) {
                        setModalState(
                          () => selectedFilePath = result.files.single.path,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      color: Documents.primaryGreen,
                    ),
                    label: Text(
                      selectedFilePath == null
                          ? 'اختيار ملف PDF من الجهاز'
                          : 'تم اختيار الملف ✓',
                      style: const TextStyle(fontFamily: 'Tajawal'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Documents.primaryGreen,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'حفظ الملف',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          selectedSubject == null ||
                          (urlController.text.isEmpty &&
                              selectedFilePath == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
                          ),
                        );
                        return;
                      }

                      final newDoc = DocumentModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        subject: selectedSubject!.name,
                        createdAt: DateTime.now(),
                        thumbnailUrl:
                            'https://cdn-icons-png.flaticon.com/512/337/337946.png',
                        documentUrl: urlController.text.isNotEmpty
                            ? urlController.text
                            : selectedFilePath!,
                      );

                      setState(() => _documents.add(newDoc));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إضافة الملف بنجاح ✅'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final DateFormat dateFormat;
  const _DocumentCard({required this.document, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    String formattedDate = dateFormat.format(document.createdAt);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PdfViewerPage(url: document.documentUrl, title: document.title),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  document.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.title,
                            style: const TextStyle(
                              color: Documents.primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'بتاريخ $formattedDate',
                            style: const TextStyle(
                              color: Documents.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.description_outlined,
                      color: Documents.iconGrey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;
  const PdfViewerPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    // ✅ (الإصلاح 2) التحقق إذا كان الرابط للشبكة أم ملف محلي
    final bool isNetwork = url.startsWith('http');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Documents.primaryGreen,
      ),
      body: isNetwork
          ? SfPdfViewer.network(url) // إذا كان رابط
          : SfPdfViewer.file(File(url)), // إذا كان ملف من الجهاز
    );
  }
}
