import 'dart:developer';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/auth/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repositories.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepositories _authLocalRepositories;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    _authLocalRepositories = ref.watch(authLocalRepositoriesProvider);
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    // initSharedPreference();
    return null;
  }

  Future<void> initSharedPreference() async {
    await _authLocalRepositories.init();
  }

  Future<void> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();

    // Call the remote repository for signup
    final res = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    // Update state based on response from the signup API
    state = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r),
    };

    log(state.toString());
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();

    // Call the remote repository for login
    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );

    // Update state based on response from the login API
    state = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _loginSuccess(r),
    };

    log(state.toString());
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepositories.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    final token = _authLocalRepositories.gettoken();

    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);

      switch (res) {
        case Left(value: final l):
          log('Error in getData: ${l.message}');
          return null;

        case Right(value: final r):
          _getDataSuccess(r);
          return r;
      }
    }

    return null;
  }

  AsyncValue<UserModel>? _getDataSuccess(UserModel user) {
    _currentUserNotifier.addUser(user);
    return AsyncValue.data(user);
  }
}
