// News Card Widget
import 'dart:developer';
import 'dart:io';

import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/main.dart';
import 'package:ramla_school/screens/news/data/news_cubit.dart';
import 'package:ramla_school/screens/news/presentation/news_details.dart';

class NewsCardWidget extends StatelessWidget {
  final NewsModel news;

  const NewsCardWidget({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsScreen(news: news),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: screenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
          boxShadow: [
            BoxShadow(
              color: iconGrey.withAlpha((0.05 * 255).round()),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // News Image
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CldImageWidget(
                  cloudinary: cloudinary,
                  publicId: news.images.first,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: dividerColor,
                    child: const Icon(Icons.error, color: offlineIndicator),
                  ),
                ),
                // Image.network(
                //   news.images.first,
                //   width: double.infinity,
                //   height: double.infinity,
                //   fit: BoxFit.cover,
                //   errorBuilder: (context, error, stackTrace) => Container(
                //     color: dividerColor,
                //     child: const Icon(Icons.error, color: offlineIndicator),
                //   ),
                //   loadingBuilder: (context, child, loadingProgress) {
                //     if (loadingProgress == null) return child;
                //     return Container(
                //       color: dividerColor,
                //       child: const Center(child: CircularProgressIndicator()),
                //     );
                //   },
                // ),
              ),
            ),
            const SizedBox(width: 16),

            // News Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.category,
                    style: const TextStyle(
                      color: chartOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? validatorMsg;
  final bool isPassword;
  final bool isConfirm;
  final bool isDropdown;
  final TextInputType keyboardType;
  final String? Function(String?)? extraValidator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validatorMsg,
    this.isPassword = false,
    this.isConfirm = false,
    this.isDropdown = false,
    this.keyboardType = TextInputType.text,
    this.extraValidator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      decoration: _buildInputDecoration(),
      validator: (value) {
        if (widget.validatorMsg != null && (value == null || value.isEmpty)) {
          return widget.validatorMsg;
        }
        if (widget.extraValidator != null) return widget.extraValidator!(value);
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: const TextStyle(color: iconGrey),
      filled: true,
      fillColor: textFieldFill,
      prefixIcon: widget.isDropdown ? null : Icon(widget.icon, color: iconGrey),
      suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: iconGrey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : (widget.isDropdown ? Icon(widget.icon, color: iconGrey) : null),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: onlineIndicator),
      ),
    );
  }
}

class AddNewsModal extends StatefulWidget {
  const AddNewsModal({super.key});

  @override
  State<AddNewsModal> createState() => __AddNewsModalState();
}

class __AddNewsModalState extends State<AddNewsModal> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ⭐️ قائمة لتخزين كائنات XFile من image_picker
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // bool _isUploading = false;

  // قائمة وهمية بالفئات
  final List<String> _categories = [
    'تكنولوجيا',
    'رياضة',
    'مال وأعمال',
    'أخبار محلية',
  ];
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 📸 منطق اختيار الصور المتعددة
  void _pickImages() async {
    // تم حذف الكود الزائد هنا واعتمدنا على الكود المُقدم في سؤالك
    final picker = ImagePicker();
    try {
      final selectedImages = await picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(selectedImages);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedImages.length} صورة تم اختيارها.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء اختيار الصور: $e')));
    }
  }

  // 🗑️ منطق حذف صورة
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 🔄 منطق استبدال صورة
  void _replaceImage(int index) async {
    try {
      final XFile? newFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (newFile != null) {
        setState(() {
          _selectedImages[index] = newFile;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استبدال الصورة بنجاح.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء استبدال الصورة: $e')),
      );
    }
  }

  void _submitForm() async {
    // ❌ حذف: final cloudinaryService = CloudinaryService();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة واحدة على الأقل للخبر.'),
        ),
      );
      return;
    }

    // ⭐️ ليس ضرورياً استخدام setState هنا، يمكن الاعتماد على حالة Cubit
    // ولكن يمكن الاحتفاظ بها لتعطيل واجهة المستخدم محلياً

    // setState(() {
    //   _isUploading = true;
    // });

    // 1. تحويل List<XFile> إلى List<File>
    final List<File> filesToUpload = _selectedImages
        .map((xFile) => File(xFile.path))
        .toList();

    try {
      // 2. 🚀 استدعاء دالة Cubit
      await context.read<NewsCubit>().createNews(
        title: _titleController.text,
        category: _selectedCategory ?? 'غير مصنف',
        description: _descriptionController.text,
        imageFiles: filesToUpload, // تمرير قائمة الملفات
      );

      // 3. ⭐️ إذا نجح الاستدعاء، سيتم إغلاق المودال ضمن الـ BlocListener
      // (يجب أن يتم تصميم شاشة المودال باستخدام BlocListener)

      // إغلاق المودال هنا إذا كنت تفضل الإغلاق المباشر
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // فشل سيتم معالجته بواسطة حالة NewsError في Cubit
      log("Submission Error (Cubit): $e");
      // هنا لا تحتاج لـ SnackBar، لأن الـ Cubit سيطلق حالة Error
      // ويجب أن يكون لديك BlocListener يراقب هذه الحالة ويعرض SnackBar.
    } finally {
      // setState(() {
      //   _isUploading = false;
      // });
    }
  }

  // 🖼️ بناء واجهة معاينة الصور
  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink(); // لا شيء للعرض إذا كانت القائمة فارغة
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Text(
            'صور الخبر (${_selectedImages.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.right,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 صور في كل صف
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final image = _selectedImages[index];
            return GestureDetector(
              onTap: () => _replaceImage(index), // النقر للاستبدال
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    // يتم عرض الصورة من مسارها المحلي
                    child: Image.file(File(image.path), fit: BoxFit.cover),
                  ),
                  // زر الحذف في الزاوية
                  Positioned(
                    top: 4,
                    left: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index), // النقر للحذف
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: screenBg),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        // هام: لضمان صعود المحتوى عند ظهور لوحة المفاتيح
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: screenBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // مقبض المودال
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: iconGrey.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                'إنشاء عنصر إخباري جديد',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // حقل عنوان الخبر
              CustomTextField(
                controller: _titleController,
                hint: 'عنوان الخبر',
                icon: Icons.title,
                validatorMsg: 'الرجاء إدخال عنوان الخبر',
              ),
              const SizedBox(height: 16),

              // قائمة الفئات المنسدلة
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'الفئة',
                  hintStyle: const TextStyle(color: iconGrey),
                  filled: true,
                  fillColor: textFieldFill,
                  prefixIcon: const Icon(Icons.category, color: iconGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: onlineIndicator),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'الرجاء اختيار فئة' : null,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, textAlign: TextAlign.right),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // حقل وصف الخبر
              CustomTextField(
                controller: _descriptionController,
                hint: 'وصف الخبر',
                icon: Icons.description,
                validatorMsg: 'الوصف لا يمكن أن يكون فارغاً',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),

              // زر اختيار الصور
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('اختيار الصور'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ⭐️ عرض الصور المختارة (المعاينة)
              _buildImagePreview(),

              const SizedBox(height: 8),

              // زر النشر
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'نشر الخبر',
                  style: TextStyle(fontSize: 18, color: screenBg),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
