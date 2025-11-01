import 'dart:developer';
import 'dart:io';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';

class CloudinaryService {
  late final Cloudinary _cloudinary;

  CloudinaryService() {
    _cloudinary = Cloudinary.fromStringUrl(
      'cloudinary://933817115344183:YLuc7hWSzrjtcOBMWvJvt8XqImI@dl0wayiab',
    );

    _cloudinary.config.urlConfig.secure = true;
  }

  /// رفع صورة من [File] محلي
  Future<String?> uploadImage(
    File file, {
    String folder = "profiles", // ✨ الفولدر الافتراضي
    bool keepHistory = false,
  }) async {
    try {
      // 👇 خلي الاسم آمن
      final safeName = currentUser!.fullName
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
          .toLowerCase();

      String publicId = safeName;
      if (keepHistory) {
        final timestamp = DateFormat(
          "yyyy_MM_dd_HHmmss",
        ).format(DateTime.now());
        publicId = "${safeName}_$timestamp";
      }

      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(
          resourceType: 'image',
          folder: folder, // ✨ الفولدر حسب النوع
          publicId: publicId,
          uniqueFilename: false,
          overwrite: !keepHistory,
        ),
      );
      return response?.data?.secureUrl;
    } catch (e) {
      log("Upload error: $e");
      return null;
    }
  }

  Future<String?> uploadNewsImage(
    File file, {
    String folder = "news", // default folder
  }) async {
    try {
      // Use the file name + timestamp to make it unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.path.split('/').last;
      final safeName = fileName
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
          .toLowerCase();
      final publicId = "${safeName}_$timestamp";

      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(
          resourceType: 'image',
          folder: folder,
          publicId: publicId,
          uniqueFilename: true,
          overwrite: false,
        ),
      );

      return response?.data?.secureUrl;
    } catch (e) {
      log("Upload error: $e");
      return null;
    }
  }

  Future<List<String>> addMultipleImages(
    List<File> files, {
    String folder = "news",
  }) async {
    List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      final url = await uploadNewsImage(file, folder: folder);

      if (url != null) urls.add(url);
    }

    return urls;
  }

  /// رفع صورة من URL
  Future<String?> uploadImageFromUrl(
    String imageUrl, {
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploader().upload(
        imageUrl,
        params: UploadParams(
          resourceType: 'image',
          publicId: publicId,
          uniqueFilename: true,
          overwrite: false,
        ),
      );
      return response?.data?.secureUrl;
    } catch (e) {
      log("Upload error: $e");
      return null;
    }
  }

  Future<void> deleteImageByUrl(String url) async {
    try {
      // Example URL:
      // https://res.cloudinary.com/dl0wayiab/image/upload/v1757701904/news/image_cropper_1757701830290_jpg_1757701901584.png

      final uri = Uri.parse(url);
      final path = uri.path;
      // path = "/image/upload/v1757701904/news/image_cropper_1757701830290_jpg_1757701901584.png"

      // Remove leading '/image/upload/' and optional version 'v1234567890/'
      final regex = RegExp(r'^/image/upload/(v\d+/)?');
      String publicId = path.replaceFirst(regex, '');

      // Remove file extension
      publicId = publicId.replaceAll(RegExp(r'\.[^/.]+$'), '');

      log("Deleting Cloudinary publicId: $publicId");
      // ✅ Should now log: news/image_cropper_1757701830290_jpg_1757701901584

      // Delete the image
      final response = await _cloudinary.uploader().destroy(
        DestroyParams(publicId: publicId, resourceType: 'image'),
      );

      if (response.responseCode == 200) {
        log("Deleted image successfully: $publicId");
      } else {
        log("Failed to delete image: $publicId, ${response.error}");
      }
    } catch (e) {
      log("Cloudinary delete error: $e");
    }
  }
}
