import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate times based on song length (just for display)
    final songDuration = const Duration(minutes: 5);
    final currentTime =
        Duration(seconds: (songDuration.inSeconds * currentProgress).round());

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
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
                        onPressed: () {
                          // Minimize player action
                        },
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
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          // Show options menu
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
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          currentSongNotifier.song_name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentSongNotifier.artist,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Progress bar with gesture detector
                        StreamBuilder(
                            stream: currentSong.audioPlayer!.positionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              }

                              final duration =
                                  currentSong.audioPlayer!.duration;
                              final position = snapshot.data;
                              double sliderValue = 0.0;
                              if (duration != null && position != null) {
                                sliderValue = position.inMilliseconds /
                                    duration.inMilliseconds;
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 6,
                                          width: sliderValue *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  32),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                hexToColor(currentSongNotifier
                                                        .hex_code)
                                                    .withValues(alpha: 0.5),
                                                hexToColor(currentSongNotifier
                                                        .hex_code)
                                                    .withValues(alpha: 1),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                        Container(
                                          height: 6,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          decoration: BoxDecoration(
                                            color: Pallete.inactiveSeekColor,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formatDuration(snapshot.data!),
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            formatDuration(currentSong
                                                .audioPlayer!.duration!),
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                        // Controls row with animations
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle button
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color:
                                    isShuffleOn ? Colors.blue : Colors.white70,
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
                                // Handle previous song
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
                                      color: Colors.blue.withValues(alpha: 0.5),
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
                                // Handle next song
                              },
                            ),

                            // Repeat button
                            IconButton(
                              icon: Icon(
                                Icons.repeat,
                                color: isRepeatOn
                                    ? hexToColor(currentSongNotifier.hex_code)
                                    : Colors.white70,
                                size: 26,
                              ),
                              onPressed: () {
                                setState(() {
                                  isRepeatOn = !isRepeatOn;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.devices_outlined,
                            color: Colors.white70),
                        onPressed: () {
                          // Show available devices
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music,
                            color: Colors.white70),
                        onPressed: () {
                          // Show queue
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white70),
                        onPressed: () {
                          // Add to favorites
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white70),
                        onPressed: () {
                          // Share song
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
