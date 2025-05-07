import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

class MusicPlayer extends ConsumerStatefulWidget {
  final VoidCallback? onExpandTap;
  const MusicPlayer({required this.onExpandTap, super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool isShuffleOn = false;
  bool isRepeatOn = false;
  double currentProgress = 0.3;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper function to format duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final currentSongNotifier = ref.watch(currentSongNotifierProvider);
    final currentSong = ref.watch(currentSongNotifierProvider.notifier);

    final screenWidth = MediaQuery.of(context).size.width;
    final currentUser = ref.watch(currentUserNotifierProvider)?.favorites;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background blur effect with album art
          if (currentSongNotifier != null &&
              currentSongNotifier.thumbnail_url.isNotEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(currentSongNotifier.thumbnail_url),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Header with drag handle and options button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 32),
                        onPressed: widget.onExpandTap,
                      ),
                      Text(
                        "NOW PLAYING",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog.adaptive(
                                title: Text(
                                  'Delete Song',
                                ),
                                content: Text(
                                  'Are you sure you want to delete this song? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (currentSongNotifier == null) return;

                                      try {
                                        // 1️⃣ Remote + in-memory delete (playlist, audio, invalidation):
                                        await ref
                                            .read(currentSongNotifierProvider
                                                .notifier)
                                            .removeSongFromPlaylist(
                                                currentSongNotifier.id);

                                        // 2️⃣ Local Hive delete + list reload:
                                        await ref
                                            .read(
                                                homeViewmodelProvider.notifier)
                                            .deleteSongFromLocal(
                                                currentSongNotifier.id);

                                        // 3️⃣ Close dialog:
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        showSnackBar(
                                          content:
                                              'Error deleting song: ${e.toString()}',
                                          context: context,
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Album artwork with animation
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Hero(
                      tag: currentSongNotifier?.song_name ?? "song_thumbnail",
                      child: Container(
                        height: screenWidth * 0.8,
                        width: screenWidth * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: hexToColor(currentSongNotifier!.hex_code)
                                  .withValues(alpha: 0.1),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(isPlaying ? 0.05 : 0.0),
                            transformAlignment: Alignment.center,
                            child: Image.network(
                              currentSongNotifier.thumbnail_url.isNotEmpty ==
                                      true
                                  ? currentSongNotifier.thumbnail_url
                                  : 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white60,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Song info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    // horizontal: 32,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  currentSongNotifier.song_name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  currentSongNotifier.artist,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Consumer(
                            builder: (_, ref, __) {
                              return IconButton(
                                icon: Icon(
                                    currentUser!
                                            .where((fav) =>
                                                fav.song_id ==
                                                currentSongNotifier.id)
                                            .toList()
                                            .isNotEmpty
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white70),
                                onPressed: () async {
                                  await ref
                                      .read(homeViewmodelProvider.notifier)
                                      .favoriteSong(currentSongNotifier.id);
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      // Progress bar with gesture detector
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: StreamBuilder(
                            stream: currentSong.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              }

                              final duration = currentSong.audioPlayer.duration;
                              final position = snapshot.data;

                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor:
                                      hexToColor(currentSongNotifier.hex_code),
                                  inactiveTrackColor: Pallete.inactiveSeekColor,
                                  thumbColor:
                                      hexToColor(currentSongNotifier.hex_code),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: hexToColor(
                                            currentSongNotifier.hex_code),
                                        blurRadius: 50,
                                      ),
                                    ],
                                  ),
                                  child: Slider(
                                    value: position != null && duration != null
                                        ? position.inMilliseconds
                                            .clamp(0, duration.inMilliseconds)
                                            .toDouble()
                                        : 0.0,
                                    min: 0.0,
                                    max: duration?.inMilliseconds.toDouble() ??
                                        0.0,
                                    onChanged: (val) {},
                                    onChangeEnd: (val) {
                                      currentSong.audioPlayer.seek(
                                        Duration(
                                          milliseconds: val.toInt(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final currentSong =
                                ref.watch(currentSongNotifierProvider.notifier);
                            return StreamBuilder<Duration>(
                                stream: currentSong.audioPlayer.positionStream,
                                builder: (context, snapshot) {
                                  final position = snapshot.data;
                                  final duration =
                                      currentSong.audioPlayer.duration;

                                  if (position == null || duration == null) {
                                    return Text("0:00");
                                  }

                                  final remaining = duration - position;

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(duration),
                                        style: TextStyle(
                                            color: Colors.white.withAlpha(150),
                                            fontSize: 12),
                                      ),
                                      Text(
                                        "- ${formatDuration(remaining)}",
                                        style: TextStyle(
                                            color: Colors.white.withAlpha(150),
                                            fontSize: 12),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                      // Controls row with animations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle button
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: isShuffleOn ? Colors.blue : Colors.white70,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                isShuffleOn = !isShuffleOn;
                              });
                            },
                          ),

                          // Previous button
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white, size: 42),
                            onPressed: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .playPrevious();
                            },
                          ),

                          // Play/Pause button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isPlaying = !isPlaying;
                                isPlaying
                                    ? _animationController.forward()
                                    : _animationController.reverse();
                              });
                            },
                            child: Container(
                              height: 76,
                              width: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    hexToColor(currentSongNotifier.hex_code)
                                        .withValues(alpha: 0.5),
                                    hexToColor(currentSongNotifier.hex_code),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: hexToColor(
                                      currentSongNotifier.hex_code,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: GestureDetector(
                                  onTap: currentSong.playPause,
                                  child: Icon(
                                    currentSong.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Next button
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white, size: 42),
                            onPressed: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .playNext();
                            },
                          ),

                          // Repeat button
                          Consumer(
                            builder: (_, ref, __) {
                              return IconButton(
                                icon: Icon(
                                  Icons.repeat,
                                  color: ref
                                          .watch(currentSongNotifierProvider
                                              .notifier)
                                          .singleLoop
                                      ? hexToColor(currentSongNotifier.hex_code)
                                      : Colors.white70,
                                  size: 26,
                                ),
                                onPressed: () {
                                  ref
                                      .watch(
                                          currentSongNotifierProvider.notifier)
                                      .setLoop();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
