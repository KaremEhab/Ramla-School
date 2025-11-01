part of 'admin_settings_cubit.dart';

abstract class AdminSettingsState extends Equatable {
  const AdminSettingsState();

  @override
  List<Object> get props => [];
}

class AdminSettingsInitial extends AdminSettingsState {}

class AdminSettingsLoading extends AdminSettingsState {}

class AdminSettingsSuccess extends AdminSettingsState {
  final String message;
  const AdminSettingsSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminSettingsFailure extends AdminSettingsState {
  final String error;
  const AdminSettingsFailure(this.error);

  @override
  List<Object> get props => [error];
}
