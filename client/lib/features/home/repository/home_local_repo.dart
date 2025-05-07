import 'dart:developer';

import 'package:client/features/home/model/song_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repo.g.dart';

@riverpod
HomeLocalRepo homeLocalRepo(Ref ref) {
  return HomeLocalRepo();
}

class HomeLocalRepo {
  Box box = Hive.box('songs');

  void uploadLocalSong(SongModel song) {
    box.put(song.id, song.toJson());
  }

  Future<bool> deleteSong(String songId) async {
    try {
      log('message');
      await box.delete(songId);
      await box.compact();
      log('$songId got delete');
      return true;
    } catch (e) {
      log('Hive deletion failed: $e');
      throw Exception('Hive deletion failed: $e');
    }
  }

  List<SongModel> loadSongs() {
    List<SongModel> songs = [];
    for (var key in box.keys) {
      songs.add(SongModel.fromJson(box.get(key)));
    }
    return songs;
  }
}
