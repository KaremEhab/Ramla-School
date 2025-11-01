import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'admin_analytics_state.dart';

class AdminAnalyticsCubit extends Cubit<AdminAnalyticsState> {
  AdminAnalyticsCubit() : super(AdminAnalyticsInitial());
}
