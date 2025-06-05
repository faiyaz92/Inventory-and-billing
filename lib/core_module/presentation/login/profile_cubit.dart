import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';


class ProfileCubit extends Cubit<ProfileState> {
  final AccountRepository accountRepository;

  ProfileCubit({
    required this.accountRepository,
  }) : super(const ProfileState.initial());

  Future<void> loadUserInfo() async {
    try {
      emit(const ProfileState.loading());
      final userInfo = await accountRepository.getUserInfo();
      if (userInfo != null) {
        emit(ProfileState.loaded(userInfo: userInfo));
      } else {
        emit(const ProfileState.error('Failed to load user information'));
      }
    } catch (e) {
      emit(ProfileState.error('Error: $e'));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      emit(const ProfileState.loading());
      await accountRepository.resetPassword(email);
      emit(const ProfileState.success('Password reset email sent'));
    } catch (e) {
      emit(ProfileState.error('Failed to reset password: $e'));
    }
  }

  void initiateLogout() {
    emit(const ProfileState.logoutRequested());
  }
}

class ProfileState extends Equatable {
  final bool isLoading;
  final UserInfo? userInfo;
  final String? message;
  final String? error;
  final bool logoutRequested;

  const ProfileState({
    required this.isLoading,
    this.userInfo,
    this.message,
    this.error,
    this.logoutRequested = false,
  });

  const ProfileState.initial()
      : isLoading = false,
        userInfo = null,
        message = null,
        error = null,
        logoutRequested = false;

  const ProfileState.loading()
      : isLoading = true,
        userInfo = null,
        message = null,
        error = null,
        logoutRequested = false;

  const ProfileState.loaded({required UserInfo userInfo})
      : isLoading = false,
        userInfo = userInfo,
        message = null,
        error = null,
        logoutRequested = false;

  const ProfileState.success(String message)
      : isLoading = false,
        userInfo = null,
        message = message,
        error = null,
        logoutRequested = false;

  const ProfileState.error(String error)
      : isLoading = false,
        userInfo = null,
        message = null,
        error = error,
        logoutRequested = false;

  const ProfileState.logoutRequested()
      : isLoading = false,
        userInfo = null,
        message = null,
        error = null,
        logoutRequested = true;

  @override
  List<Object?> get props => [isLoading, userInfo, message, error, logoutRequested];
}