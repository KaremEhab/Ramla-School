import 'dart:developer';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/core/services/cloudinary_services.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NewsCubit() : super(NewsInitial());

  // ----------------------------------------------------
  // 📥 جلب جميع الأخبار
  // ----------------------------------------------------
  Future<void> fetchNews() async {
    emit(const NewsLoading(message: 'جاري جلب الأخبار...'));
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('createdAt', descending: true)
          .get();

      final newsList = snapshot.docs.map((doc) {
        // نمرر الـ ID لاستخدامه في التعديل والحذف
        return NewsModel.fromJson(doc.data()).copyWith(id: doc.id);
      }).toList();

      emit(NewsLoaded(newsList: newsList));
    } catch (e) {
      log('Fetch News Error: $e');
      emit(NewsError(error: 'فشل جلب الأخبار: $e'));
    }
  }

  // ----------------------------------------------------
  // ➕ إنشاء خبر جديد
  // ----------------------------------------------------
  Future<void> createNews({
    required String title,
    required String category,
    required String description,
    required List<File> imageFiles,
  }) async {
    emit(const NewsLoading(message: 'جاري رفع الصور ونشر الخبر...'));
    List<String> uploadedUrls = [];
    final cloudinaryService = CloudinaryService();
    try {
      // 1. رفع الصور إلى Cloudinary
      uploadedUrls = await cloudinaryService.addMultipleImages(
        imageFiles,
        folder: "news",
      );

      if (uploadedUrls.isEmpty) {
        throw Exception("فشل تحميل الصور إلى Cloudinary.");
      }

      // 2. تجهيز نموذج البيانات
      final newNews = NewsModel(
        title: title,
        category: category,
        description: description,
        createdAt: DateTime.now(),
        images: uploadedUrls,
      );

      // 3. إضافة المستند إلى Firestore
      await _firestore.collection('news').add(newNews.toJson());

      emit(const NewsSuccess(message: 'تم نشر الخبر بنجاح!'));
      fetchNews(); // تحديث قائمة الأخبار بعد الإنشاء
    } catch (e) {
      log('Create News Error: $e');
      // 💡 TODO: إذا فشل النشر، يجب التفكير في حذف الصور المرفوعة من Cloudinary
      emit(NewsError(error: 'فشل في إنشاء الخبر: $e'));
    }
  }

  // ----------------------------------------------------
  // ✏️ تعديل خبر موجود
  // ----------------------------------------------------
  Future<void> updateNews({
    required String id,
    required String title,
    required String category,
    required String description,
    required List<String> existingImages, // الروابط التي لم تتغير
    required List<File> newImageFiles, // الملفات الجديدة التي سيتم رفعها
    required List<String>
    imagesToDelete, // الروابط التي يجب حذفها من Cloudinary
  }) async {
    emit(const NewsLoading(message: 'جاري تحديث الخبر...'));
    List<String> finalUrls = [...existingImages]; // ابدأ بالروابط القديمة
    final cloudinaryService = CloudinaryService();
    try {
      // 1. حذف الصور القديمة من Cloudinary
      for (final url in imagesToDelete) {
        await cloudinaryService.deleteImageByUrl(url);
      }

      // 2. رفع الصور الجديدة إلى Cloudinary
      if (newImageFiles.isNotEmpty) {
        final newUrls = await cloudinaryService.addMultipleImages(
          newImageFiles,
          folder: "news",
        );
        finalUrls.addAll(newUrls);
      }

      if (finalUrls.isEmpty) {
        throw Exception("يجب أن يحتوي الخبر على صورة واحدة على الأقل.");
      }

      // 3. تجهيز نموذج البيانات
      final updatedData = NewsModel(
        title: title,
        category: category,
        description: description,
        createdAt: DateTime.now(), // يمكنك تحديث تاريخ الإنشاء أو تركه
        images: finalUrls,
      ).toJson();

      // 4. تحديث المستند في Firestore
      await _firestore.collection('news').doc(id).update(updatedData);

      emit(const NewsSuccess(message: 'تم تعديل الخبر بنجاح!'));
      fetchNews(); // تحديث القائمة
    } catch (e) {
      log('Update News Error: $e');
      emit(NewsError(error: 'فشل في تعديل الخبر: $e'));
    }
  }

  // ----------------------------------------------------
  // 🗑️ حذف خبر
  // ----------------------------------------------------
  Future<void> deleteNews({
    required String id,
    required List<String> images,
  }) async {
    emit(const NewsLoading(message: 'جاري حذف الخبر...'));
    final cloudinaryService = CloudinaryService();
    try {
      // 1. حذف جميع الصور المرتبطة من Cloudinary
      for (final url in images) {
        await cloudinaryService.deleteImageByUrl(url);
      }

      // 2. حذف المستند من Firestore
      await _firestore.collection('news').doc(id).delete();

      emit(const NewsSuccess(message: 'تم حذف الخبر بنجاح!'));
      fetchNews(); // تحديث قائمة الأخبار بعد الحذف
    } catch (e) {
      log('Delete News Error: $e');
      emit(NewsError(error: 'فشل في حذف الخبر: $e'));
    }
  }
}
