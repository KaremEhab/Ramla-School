part of 'admin_analytics_cubit.dart';

abstract class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState();

  @override
  List<Object> get props => [];
}

class AdminAnalyticsInitial extends AdminAnalyticsState {}

class AdminAnalyticsLoading extends AdminAnalyticsState {}

class AdminAnalyticsLoaded extends AdminAnalyticsState {
  final AnalyticsModel data;
  const AdminAnalyticsLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class AdminAnalyticsFailure extends AdminAnalyticsState {
  final String error;
  const AdminAnalyticsFailure(this.error);

  @override
  List<Object> get props => [error];
}
