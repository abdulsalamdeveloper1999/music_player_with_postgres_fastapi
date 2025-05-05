import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${Platform.isAndroid ? ServerConstants.androidServerUrl : ServerConstants.iosServerUrl}/auth/signup",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      final responseMapBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        return Left(AppFailure(responseMapBody['detail']));
      }

      return Right(UserModel.fromMap(responseMapBody));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    // log("$email $password");
    try {
      final response = await http.post(
        Uri.parse(
          "${Platform.isAndroid ? ServerConstants.androidServerUrl : ServerConstants.iosServerUrl}/auth/login",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      // log(response.statusCode.toString());

      final jsonDecodeMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(jsonDecodeMap['detail']));
      }

      return Right(
        UserModel.fromMap(jsonDecodeMap['user'])
            .copyWith(token: jsonDecodeMap['token']),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
          Uri.parse(
            "${Platform.isAndroid ? ServerConstants.androidServerUrl : ServerConstants.iosServerUrl}/auth/",
          ),
          headers: {'x-auth-token': token});

      final jsonMapData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(jsonMapData['detail']));
      }

      return Right(UserModel.fromMap(jsonMapData).copyWith(token: token));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
