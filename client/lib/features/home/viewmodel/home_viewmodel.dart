import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/home/model/favorite_song_model.dart';
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
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
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
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
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
    ref.invalidate(getAllFavSongsProvider);
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
      Right(value: final r) => state = _favSongSuccess(r, songId)
    };
    // log(val.toString());
    state = val;
  }

  AsyncValue _favSongSuccess(bool isFavorite, String songId) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavorite) {
      userNotifier
          .addUser(ref.read(currentUserNotifierProvider)!.copyWith(favorites: [
        ...ref.read(currentUserNotifierProvider)!.favorites,
        FavoriteSongModel(
          id: '',
          song_id: songId,
          user_id: '',
        )
      ]));
    } else {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
            favorites: ref
                .read(currentUserNotifierProvider)!
                .favorites
                .where((fav) => fav.song_id != songId)
                .toList()),
      );
    }
    ref.invalidate(getAllFavSongsProvider);
    return state = AsyncValue.data(isFavorite);
  }

  Future<void> deleteSong(String songId) async {
    final token =
        ref.read(currentUserNotifierProvider.select((user) => user!.token!));
    state = AsyncValue.loading();
    final res = await ref.read(homeRepositoryProvider).deleteSong(
          songId,
          token,
        );

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(l, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r)
    };

    state = val;
  }

  Future<void> deleteSongFromLocal(String songId) async {
    try {
      final localRepo = ref.read(homeLocalRepoProvider);
      final success = await localRepo.deleteSong(songId);
      if (!success) {
        throw Exception('Failed to delete song locally');
      }
      // If you have a separate provider for all songs:
      ref.invalidate(getAllSongsProvider);

      // Or, if this StateNotifier itself holds the list in `state`:
      final updated = localRepo.loadSongs();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      log('Local delete error: $e');
      // Propagate to UI
      state = AsyncValue.error(e, st);
    }
  }
}
