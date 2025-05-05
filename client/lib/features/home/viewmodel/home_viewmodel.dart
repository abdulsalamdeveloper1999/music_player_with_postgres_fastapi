import 'dart:io';
import 'dart:ui';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/auth/widgets/utils.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repository/home_local_repo.dart';
import 'package:client/features/home/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(Ref ref) async {
  final token = ref.watch(currentUserNotifierProvider)!.token;
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(
        token: token!,
      );

  final val = switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r
  };

  return val;
}

@riverpod
Future<List<SongModel>> getAllFavSongs(Ref ref) async {
  final token = ref.read(currentUserNotifierProvider)?.token;
  final res = await ref.read(homeRepositoryProvider).getallFavoritesSongs(
        token: token!,
      );

  final val = switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r
  };

  return val;
}

@riverpod
class HomeViewmodel extends _$HomeViewmodel {
  late HomeLocalRepo _homeLocalRepo;
  late HomeRepository _homeRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepo = ref.watch(homeLocalRepoProvider);
    return null;
  }

  Future<void> uploadSong({
    required File selectedaudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color selectedColor,
  }) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.uploadSong(
      selectedaudio: selectedaudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artist: artist,
      hexcode: rgbToHex(selectedColor),
      token: ref.read(currentUserNotifierProvider)!.token!,
    );

    final val = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r),
    };

    state = val;
  }

  List<SongModel> getRecentlyPlayedSong() {
    return _homeLocalRepo.loadSongs();
  }

  Future<void> favoriteSong(String songId) async {
    state = AsyncValue.loading();
    final res = await _homeRepository.toggleFav(
      songId,
      ref.read(currentUserNotifierProvider)!.token!,
    );

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r)
    };

    state = val;
  }

  AsyncValue _favSongSuccess(bool isFavorite, String songId) {
    return state = AsyncValue.data(isFavorite);
  }
}
