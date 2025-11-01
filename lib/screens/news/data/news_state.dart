part of 'news_cubit.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

/// 🚀 حالة البدء الأولية
class NewsInitial extends NewsState {}

/// 🔄 حالة التحميل (لجميع العمليات: جلب، إنشاء، تعديل، حذف)
class NewsLoading extends NewsState {
  final String message;
  const NewsLoading({this.message = 'جاري المعالجة...'});

  @override
  List<Object?> get props => [message];
}

/// ✅ حالة النجاح العام
class NewsSuccess extends NewsState {
  final String message;
  const NewsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ❌ حالة الفشل العام
class NewsError extends NewsState {
  final String error;
  const NewsError({required this.error});

  @override
  List<Object?> get props => [error];
}

// ----------------------------------------------------
// حالات جلب الأخبار (لقائمة الأخبار)
// ----------------------------------------------------

/// ✅ حالة نجاح جلب قائمة الأخبار
class NewsLoaded extends NewsState {
  final List<NewsModel> newsList;
  const NewsLoaded({required this.newsList});

  @override
  List<Object?> get props => [newsList];
}
