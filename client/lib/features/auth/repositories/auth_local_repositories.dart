import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'auth_local_repositories.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepositories authLocalRepositories(Ref ref) {
  return AuthLocalRepositories();
}

class AuthLocalRepositories {
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setToken(String? token) async {
    if (token != null) {
      await _sharedPreferences.setString('x-auth-token', token);
    }
  }

  void removeToken() {
    _sharedPreferences.remove('x-auth-token');
  }

  String? gettoken() {
    return _sharedPreferences.getString('x-auth-token');
  }
}
