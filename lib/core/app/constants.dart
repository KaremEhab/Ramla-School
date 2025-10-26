import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/core/models/notifications_model.dart';
import 'package:ramla_school/core/models/subject_model.dart';

enum UserRole {
  student,
  teacher,
  admin;

  // Helper to convert string from Firestore to an enum
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.student, // Default fallback
    );
  }
}

enum UserStatus {
  online,
  offline;

  // Helper to convert string from Firestore to an enum
  static UserStatus fromString(String status) {
    return UserStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => UserStatus.offline, // Default fallback
    );
  }
}

enum Gender {
  male,
  female,
  other;

  // Helper to convert string from Firestore to an enum
  static Gender fromString(String gender) {
    return Gender.values.firstWhere(
      (e) => e.name == gender,
      orElse: () => Gender.other, // Default fallback
    );
  }
}

// grade_enum.dart
enum Grade { grade6, grade7, grade8, grade9 }

extension GradeExtension on Grade {
  String get label {
    switch (this) {
      case Grade.grade6:
        return '6';
      case Grade.grade7:
        return '7';
      case Grade.grade8:
        return '8';
      case Grade.grade9:
        return '9';
    }
  }

  int get numberOfClasses {
    switch (this) {
      case Grade.grade6:
        return 7;
      case Grade.grade7:
        return 6;
      case Grade.grade8:
        return 6;
      case Grade.grade9:
        return 5;
    }
  }
}

// subject_enum.dart
enum SchoolSubject {
  math,
  science,
  fitness,
  music,
  islamic,
  computer,
  geography,
  english,
  arabic,
  houseEconomics,
  practicalStudies,
  art,
}

extension SubjectExtension on SchoolSubject {
  String get name {
    switch (this) {
      case SchoolSubject.math:
        return 'الرياضيات';
      case SchoolSubject.science:
        return 'العلوم';
      case SchoolSubject.fitness:
        return 'التربية البدنية';
      case SchoolSubject.music:
        return 'التربية الموسيقية';
      case SchoolSubject.islamic:
        return 'التربية الاسلامية';
      case SchoolSubject.computer:
        return 'الحاسب الآلي';
      case SchoolSubject.geography:
        return 'الاجتماعيات';
      case SchoolSubject.english:
        return 'اللغة الانجليزية';
      case SchoolSubject.arabic:
        return 'اللغة العربية';
      case SchoolSubject.houseEconomics:
        return 'الاقتصاد المنزلي';
      case SchoolSubject.practicalStudies:
        return 'الدراسات العملية';
      case SchoolSubject.art:
        return 'التربية الفنية';
    }
  }

  /// Check if a subject applies to a certain grade
  bool isAvailableFor(Grade grade) {
    switch (this) {
      case SchoolSubject.practicalStudies:
        return grade == Grade.grade6 || grade == Grade.grade8;
      case SchoolSubject.art:
        return grade == Grade.grade7 || grade == Grade.grade9;
      default:
        return true;
    }
  }
}

UserRole? currentRole;

// Dummy news list (replace this later with your backend data)
final List<NewsModel> newsList = [
  NewsModel(
    title: "تعليمات هامة للعام الدراسي الجديد",
    category: "قوانين هامة",
    description:
        "تعلن إدارة المدرسة عن تعليمات هامة للعام الدراسي الجديد، "
        "يرجى من جميع الطلاب وأولياء الأمور الالتزام بها لضمان سير العملية التعليمية بنجاح.",
    createdAt: DateTime(2025, 9, 10),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/Y3HcbM5/sample2.png",
    ],
  ),
  NewsModel(
    title: "بدء التسجيل للأنشطة الطلابية للفصل الأول",
    category: "أنشطة",
    description:
        "يسر المدرسة الإعلان عن بدء التسجيل في الأنشطة الطلابية المختلفة، "
        "يمكن للطلاب التسجيل من خلال التطبيق أو مكتب النشاط.",
    createdAt: DateTime(2025, 9, 15),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/4t6pVRL/sample3.png",
    ],
  ),
  NewsModel(
    title: "إعلان عن جدول الامتحانات النهائية للصفوف العليا",
    category: "إعلانات",
    description:
        "نُعلن عن جدول الامتحانات النهائية للفصل الدراسي الأول، "
        "يرجى من الطلاب مراجعة الجدول المعلن في لوحة الإعلانات أو عبر التطبيق.",
    createdAt: DateTime(2025, 11, 1),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/vq4HvMM/sample4.png",
    ],
  ),
  NewsModel(
    title: "رحلة علمية إلى متحف التاريخ الطبيعي",
    category: "فعاليات",
    description:
        "تنظم المدرسة رحلة علمية إلى متحف التاريخ الطبيعي لطلاب الصف السادس، "
        "وذلك يوم الخميس القادم، نرجو الالتزام بالموعد المحدد للحضور.",
    createdAt: DateTime(2025, 10, 5),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/Y3HcbM5/sample2.png",
    ],
  ),
  NewsModel(
    title: "مسابقة أفضل مشروع علمي",
    category: "أنشطة",
    description:
        "تعلن لجنة الأنشطة عن بدء استقبال المشاريع المشاركة في مسابقة أفضل مشروع علمي، "
        "آخر موعد للتقديم هو نهاية هذا الأسبوع.",
    createdAt: DateTime(2025, 10, 12),
    images: [
      "https://i.ibb.co/vq4HvMM/sample4.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
  NewsModel(
    title: "تكريم الطلاب المتفوقين للفصل الماضي",
    category: "إعلانات",
    description:
        "يسر إدارة المدرسة الإعلان عن إقامة حفل تكريم للطلاب المتفوقين "
        "في نتائج الفصل الماضي، وذلك يوم الاثنين المقبل في قاعة الأنشطة.",
    createdAt: DateTime(2025, 9, 30),
    images: [
      "https://i.ibb.co/4t6pVRL/sample3.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
  NewsModel(
    title: "تحديث النظام الإلكتروني للمدرسة",
    category: "إعلانات",
    description:
        "تم تحديث نظام المدرسة الإلكتروني لتسهيل عملية الاطلاع على الدرجات والواجبات، "
        "يرجى من أولياء الأمور والطلاب تحديث التطبيق إلى آخر إصدار.",
    createdAt: DateTime(2025, 9, 25),
    images: [
      "https://i.ibb.co/Y3HcbM5/sample2.png",
      "https://i.ibb.co/vq4HvMM/sample4.png",
    ],
  ),
  NewsModel(
    title: "ورشة عمل حول السلامة المرورية",
    category: "توعية",
    description:
        "ضمن برامج التوعية، ستقام ورشة عمل عن السلامة المرورية يوم الأحد القادم "
        "بمشاركة ممثلين من إدارة المرور.",
    createdAt: DateTime(2025, 10, 8),
    images: [
      "https://i.ibb.co/4t6pVRL/sample3.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
  NewsModel(
    title: "بدء حملة تنظيف البيئة المدرسية",
    category: "أنشطة",
    description:
        "تطلق المدرسة حملة لتنظيف البيئة المدرسية بمشاركة الطلاب والمعلمين، "
        "تهدف الحملة إلى تعزيز قيم النظافة والانتماء.",
    createdAt: DateTime(2025, 10, 18),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/Y3HcbM5/sample2.png",
    ],
  ),
  NewsModel(
    title: "افتتاح مختبر العلوم الجديد",
    category: "إعلانات",
    description:
        "تم بحمد الله افتتاح مختبر العلوم الحديث المجهز بأحدث الأدوات والتقنيات، "
        "وسيبدأ استخدامه في الحصص العملية الأسبوع القادم.",
    createdAt: DateTime(2025, 9, 28),
    images: [
      "https://i.ibb.co/vq4HvMM/sample4.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
  NewsModel(
    title: "مسابقة الرسم الحر للطلاب",
    category: "أنشطة فنية",
    description:
        "تُقام مسابقة الرسم الحر يوم الخميس القادم في قاعة الفنون، "
        "وسيتم توزيع الجوائز على الفائزين في الطابور الصباحي.",
    createdAt: DateTime(2025, 10, 20),
    images: [
      "https://i.ibb.co/4t6pVRL/sample3.png",
      "https://i.ibb.co/vq4HvMM/sample4.png",
    ],
  ),
  NewsModel(
    title: "تفعيل نظام الحضور والانصراف بالبصمة",
    category: "إعلانات",
    description:
        "تعلن إدارة المدرسة عن بدء تفعيل نظام البصمة للحضور والانصراف لجميع العاملين "
        "بدءاً من الأسبوع القادم.",
    createdAt: DateTime(2025, 10, 1),
    images: [
      "https://i.ibb.co/0V9dQbBL/news.png",
      "https://i.ibb.co/Y3HcbM5/sample2.png",
    ],
  ),
  NewsModel(
    title: "محاضرة توعوية حول الاستخدام الآمن للإنترنت",
    category: "توعية",
    description:
        "ضمن جهود المدرسة في التوعية الرقمية، سيتم تنظيم محاضرة حول الاستخدام الآمن "
        "لشبكة الإنترنت لطلاب المرحلة الإعدادية.",
    createdAt: DateTime(2025, 10, 22),
    images: [
      "https://i.ibb.co/4t6pVRL/sample3.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
  NewsModel(
    title: "توزيع الكتب الدراسية للفصل الثاني",
    category: "إعلانات",
    description:
        "يبدأ توزيع الكتب الدراسية للفصل الدراسي الثاني يوم الأحد القادم، "
        "يرجى من الطلاب إحضار الحقائب لاستلام الكتب.",
    createdAt: DateTime(2025, 11, 3),
    images: [
      "https://i.ibb.co/vq4HvMM/sample4.png",
      "https://i.ibb.co/Y3HcbM5/sample2.png",
    ],
  ),
  NewsModel(
    title: "احتفال اليوم الوطني بفعاليات متنوعة",
    category: "فعاليات",
    description:
        "تحتفل المدرسة باليوم الوطني من خلال فعاليات ومسابقات ثقافية وتراثية، "
        "ندعو جميع الطلاب للمشاركة والتفاعل.",
    createdAt: DateTime(2025, 9, 23),
    images: [
      "https://i.ibb.co/4t6pVRL/sample3.png",
      "https://i.ibb.co/0V9dQbBL/news.png",
    ],
  ),
];

// --- Mock Data ---
final List<NotificationModel> notifications = [
  NotificationModel(
    id: '1',
    title: 'تنويه هام',
    body: 'سيتم تعطيل الدراسة غداً بسبب الاحوال الجوية',
    timeAgo: 'منذ 1 دقيقة',
    imageUrl: 'https://placehold.co/60x60/F39C12/FFFFFF?text=!', // Orange !
    isNew: true,
  ),
  NotificationModel(
    id: '2',
    title: 'تنويه هام',
    body: 'سيتم تعطيل الدراسة غداً بسبب الاحوال الجوية',
    timeAgo: 'منذ 1 دقيقة',
    imageUrl: 'https://placehold.co/60x60/F39C12/FFFFFF?text=!', // Orange !
    isNew: true,
  ),
  NotificationModel(
    id: '3',
    title: 'تنويه هام',
    body: 'سيتم تعطيل الدراسة غداً بسبب الاحوال الجوية',
    timeAgo: 'منذ 1 دقيقة',
    imageUrl: 'https://placehold.co/60x60/AAAAAA/FFFFFF?text=i', // Grey i
    isNew: false,
  ),
  NotificationModel(
    id: '4',
    title: 'تنويه هام',
    body: 'سيتم تعطيل الدراسة غداً بسبب الاحوال الجوية',
    timeAgo: 'منذ 1 دقيقة',
    imageUrl: 'https://placehold.co/60x60/AAAAAA/FFFFFF?text=i', // Grey i
    isNew: false,
  ),
];
