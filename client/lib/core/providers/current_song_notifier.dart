import 'dart:developer';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repository/home_local_repo.dart';
import 'package:client/features/home/repository/home_repository.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:fpdart/fpdart.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepo homeLocalRepo;
  AudioPlayer audioPlayer = AudioPlayer();
  // bool isPlaying = false;
  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool singleLoop = false;
  bool _skipNextSequence = false;
  List<SongModel> get currentPlaylist => _playlist;

  @override
  SongModel? build() {
    homeLocalRepo = ref.watch(homeLocalRepoProvider);

    // Listen for sequence changes, but skip the first one right after loading
    audioPlayer.sequenceStateStream.listen((seqState) {
      if (_skipNextSequence) {
        _skipNextSequence = false;
        return;
      }

      final newIndex = seqState.currentIndex;
      if (newIndex != null && newIndex != _currentIndex) {
        _currentIndex = newIndex;
        state = _playlist[newIndex];
        homeLocalRepo.uploadLocalSong(_playlist[newIndex]);
      }

      _updateState();
    });

    audioPlayer.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        if (audioPlayer.hasNext) {
          playNext();
        } else {
          // Track ended and no next track
          audioPlayer.stop().then((_) {
            state = state!.copyWith(hex_code: state!.hex_code);
          });
        }
      }
    });

    return null;
  }

  // Add playing state to your model
  bool get isPlaying => audioPlayer.playing;

  void setPlaylist(List<SongModel> playlist, int startIndex) async {
    // Create a loading state if you want
    // state = state?.copyWith(isLoading: true);

    _playlist = List.from(playlist);
    _currentIndex = startIndex;

    // Set flag to ignore next sequence update
    _skipNextSequence = true;

    // Don't call updateState here - it'll be called in updateSong
    updateSong(_playlist[_currentIndex]);
  }

  void _updateState() {
    state = state?.copyWith(hex_code: state?.hex_code ?? '#FFFFFF');
  }

  void updateSong(SongModel song) async {
    try {
      // First stop current playback
      await audioPlayer.stop();

      // Set UI state after stopping
      state = song;

      // Important: Clear all existing audio sources
      await audioPlayer.clearAudioSources();

      // For debugging
      log('🎵 Updating to song: ${song.song_name} with URL: ${song.song_url}');

      // IMPORTANT CHANGE: We need to update our internal playlist tracking BEFORE setting audio sources
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        // Song not found in playlist - fallback
        _currentIndex = 0;
      }

      // Build the complete playlist sources
      final sources = _playlist
          .map((playlistSong) => AudioSource.uri(
                Uri.parse(playlistSong.song_url),
                tag: MediaItem(
                  id: playlistSong.id,
                  title: playlistSong.song_name,
                  artist: playlistSong.artist,
                  artUri: Uri.parse(playlistSong.thumbnail_url),
                ),
              ))
          .toList();

      // Set the flag to ignore sequence updates
      _skipNextSequence = true;

      // Load the full playlist immediately but with the correct initial index
      await audioPlayer.setAudioSources(
        sources,
        initialIndex: _currentIndex, // This is crucial - play the right song
        initialPosition: Duration.zero,
      );

      // Reset flag for future updates
      _skipNextSequence = false;

      // Start playback only after everything is set up
      await audioPlayer.play();

      // Update local repository
      homeLocalRepo.uploadLocalSong(song);
    } catch (e) {
      log('🎧 Error in updateSong: $e');
      _skipNextSequence = false;
      state = null;
    }
  }

  void playPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    // isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  Future setLoop() async {
    singleLoop = !singleLoop;
    if (singleLoop) {
      audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioPlayer.setLoopMode(LoopMode.off);
    }
    _updateState();
  }

  // 7aox03-1V21JXEpIXTz7UtHSlM71KzJ9JfHwsIj7skQIpkttBUi9KqI4sWmlVCXH

  Future<void> playNext() async {
    if (audioPlayer.hasNext) {
      await audioPlayer.seekToNext();
      await audioPlayer.play();
    } else {
      // No next track—stop first...
      // await audioPlayer.stop();
      // ...then force Riverpod to re-emit current song so UI rebuilds
      state = state!.copyWith(hex_code: state!.hex_code);
    }
  }

  void playPrevious() async {
    if (audioPlayer.previousIndex != null) {
      await audioPlayer.stop();
      await audioPlayer.seekToPrevious();
      await audioPlayer.play();
    }
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  Future<void> removeSongFromPlaylist(String songId) async {
    final token = ref.read(currentUserNotifierProvider.select((u) => u!.token));

    // Call the delete API
    final res =
        await ref.read(homeRepositoryProvider).deleteSong(songId, token!);

    switch (res) {
      case Left(value: final failure):
        log('❌ Failed to delete song: ${failure.message}');
        break;

      case Right(value: final _):
        final removeIndex = _playlist.indexWhere((song) => song.id == songId);
        if (removeIndex == -1) return;

        final wasCurrent = removeIndex == _currentIndex;

        // Remove from playlist
        _playlist.removeAt(removeIndex);

        // Remove from audio source
        await audioPlayer.removeAudioSourceAt(removeIndex);

        // Update UI data
        ref.invalidate(getAllSongsProvider);
        log('$songId is deleted from hive');

        if (wasCurrent) {
          if (_playlist.isEmpty) {
            // No songs left
            await audioPlayer.stop();
            state = null;
          } else {
            // Play next available song
            _currentIndex = removeIndex < _playlist.length
                ? removeIndex
                : _playlist.length - 1;
            updateSong(_playlist[_currentIndex]);
          }
        } else {
          // Not the current song, just adjust currentIndex if needed
          if (_currentIndex > removeIndex) {
            _currentIndex--;
          }
          _updateState();
        }
        break;
    }
  }
}
