import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

final url = Platform.isIOS
    ? ServerConstants.iosServerUrl
    : ServerConstants.androidServerUrl;

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong(
      {required File selectedaudio,
      required File selectedThumbnail,
      required String songName,
      required String artist,
      required String hexcode,
      required String token}) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$url/song/upload'));

      request
        ..files.addAll([
          await http.MultipartFile.fromPath('song', selectedaudio.path),
          await http.MultipartFile.fromPath(
              'thumbnail', selectedThumbnail.path),
        ])
        ..fields.addAll(
            {'artist': artist, 'song_name': songName, 'hex_code': hexcode})
        ..headers.addAll(
          {'x-auth-token': token},
        );

      final response = await request.send();
      // log('Request sent to: ${request.url}');
      // log('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorResponse = await response.stream.bytesToString();
        return Left(AppFailure(errorResponse));
      }
      return Right(await response.stream.bytesToString());
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs(
      {required String token}) async {
    try {
      final res = await http.get((Uri.parse('$url/song/list')), headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });
      var resBodyMap = jsonDecode(res.body);
      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      resBodyMap as List;
      List<SongModel> songs = [];

      for (var map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }

      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> toggleFav(
      String songId, String token) async {
    try {
      final res = await http.post(Uri.parse('$url/song/favorite'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({'song_id': songId}));
      final data = jsonDecode(res.body);
      if (res.statusCode != 200) {
        return Left(AppFailure(data['detail']));
      }

      return Right(data['message'] as bool);
    } catch (e) {
      log(e.toString());
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getallFavoritesSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$url/song/list/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        final resBody = jsonDecode(res.body) as Map<String, dynamic>;
        return Left(AppFailure(resBody['detail']));
      }

      final List<dynamic> resBody = jsonDecode(res.body);

      // Parse each favorite item -> extract 'song' -> convert to SongModel
      final List<SongModel> favSongs =
          resBody.map((e) => SongModel.fromMap(e['song'])).toList();

      return Right(favSongs);
    } catch (e) {
      // log(e.toString());
      return Left(AppFailure(e.toString()));
    }
  }
}
