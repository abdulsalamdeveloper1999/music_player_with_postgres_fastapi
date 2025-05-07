import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/music_theme.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/auth/repositories/auth_local_repositories.dart';
import 'package:client/features/auth/views/login_page.dart';
import 'package:client/features/home/repository/home_local_repo.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedSongs =
        ref.read(homeViewmodelProvider.notifier).getRecentlyPlayedSong();
    final currentSong = ref.watch(currentSongNotifierProvider);
    // final currentUser = ref.read(currentUserNotifierProvider);

    return MusicThemeBackground(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: currentSong != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    hexToColor(currentSong.hex_code).withValues(alpha: 0.8),
                    hexToColor(currentSong.hex_code).withValues(alpha: 0.3),
                    Pallete.transparentColor,
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Pallete.cardColor.withValues(alpha: 0.5),
                    Pallete.transparentColor,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header with animated gradient
                Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: currentSong != null
                                      ? hexToColor(currentSong.hex_code)
                                          .withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Pallete.cardColor,
                              radius: 18,
                              child: Icon(
                                Icons.music_note,
                                size: 22,
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Your Music",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ref
                              .read(currentUserNotifierProvider.notifier)
                              .removeUser();
                          ref.read(authLocalRepositoriesProvider).removeToken();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => LoginPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Pallete.cardColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.logout,
                            size: 24,
                            color: Pallete.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Recently Played Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history,
                              size: 16,
                              color: Pallete.whiteColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Recently Played",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    Pallete.whiteColor.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (recentlyPlayedSongs.isEmpty)
                  // Empty state for Recently Played
                  Container(
                    height: 160,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Pallete.cardColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Pallete.whiteColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.headphones_outlined,
                          size: 48,
                          color: Pallete.whiteColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No recently played songs",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Pallete.whiteColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Play some music to see it here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Pallete.whiteColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Recently Played Songs Grid
                  SizedBox(
                    height: recentlyPlayedSongs.length <= 3 ? 85 : 380,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: recentlyPlayedSongs.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 3,
                      ),
                      itemBuilder: (context, index) {
                        final song = recentlyPlayedSongs[index];
                        final isPlaying =
                            currentSong != null && currentSong.id == song.id;
                        return GestureDetector(
                          onTap: () {
                            final notifier =
                                ref.read(currentSongNotifierProvider.notifier);
                            final allSongs =
                                ref.read(getAllSongsProvider).value ?? [];
                            final startIndex =
                                allSongs.indexWhere((s) => s.id == song.id);
                            if (startIndex != -1) {
                              notifier.setPlaylist(allSongs, startIndex);
                            } else {
                              notifier.updateSong(song);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Pallete.cardColor.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: currentSong != null &&
                                          currentSong.id == song.id
                                      ? hexToColor(currentSong.hex_code)
                                          .withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: isPlaying
                                  ? Border.all(
                                      color: hexToColor(currentSong.hex_code)
                                          .withValues(alpha: 0.8),
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'thumbnail-${song.id}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      song.thumbnail_url,
                                      height: double.infinity,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: double.infinity,
                                          width: 70,
                                          color: Pallete.cardColor
                                              .withValues(alpha: 0.7),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Pallete.whiteColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        song.song_name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Pallete.whiteColor
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Latest Today Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.new_releases_outlined,
                              size: 16,
                              color: Pallete.whiteColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Latest Today',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    Pallete.whiteColor.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 12, vertical: 4),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Pallete.whiteColor.withValues(alpha: 0.2),
                      //       width: 1,
                      //     ),
                      //     borderRadius: BorderRadius.circular(14),
                      //   ),
                      //   child: Text(
                      //     'See All',
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.w500,
                      //       color: Pallete.whiteColor.withValues(alpha: 0.8),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                ref.watch(getAllSongsProvider).when(
                  data: (songs) {
                    if (songs.isEmpty) {
                      // Empty state for Latest Today
                      return Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Pallete.cardColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Pallete.whiteColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: currentSong != null
                                        ? [
                                            hexToColor(currentSong.hex_code),
                                            Colors.purple,
                                          ]
                                        : [
                                            Colors.blue,
                                            Colors.purple,
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.album_outlined,
                                  size: 72,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No new releases today",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Pallete.whiteColor.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Check back later for new music",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Pallete.whiteColor.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 16,
                              //     vertical: 8,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: currentSong != null
                              //         ? hexToColor(currentSong.hex_code)
                              //             .withValues(alpha: 0.3)
                              //         : Pallete.cardColor.withValues(alpha: 0.6),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: const Text(
                              //     "Browse All Music",
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: songs.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) {
                          final song = songs[index];
                          final isPlaying =
                              currentSong != null && currentSong.id == song.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                final currentSong =
                                    ref.read(currentSongNotifierProvider);
                                final notifier = ref
                                    .read(currentSongNotifierProvider.notifier);

                                // 1. Check if tapped song is already playing
                                if (currentSong?.id == song.id) {
                                  // Just toggle play/pause
                                  notifier.playPause();
                                  return;
                                }

                                // 2. Get the CORRECT playlist context
                                final currentPlaylist =
                                    notifier.currentPlaylist;
                                final songsFromProvider =
                                    ref.read(getAllSongsProvider).value ?? [];

                                // 3. Find song in current playlist first
                                final existingIndex = currentPlaylist
                                    .indexWhere((s) => s.id == song.id);

                                if (existingIndex != -1) {
                                  // 4. If found in current playlist, play from there
                                  notifier.setPlaylist(
                                      currentPlaylist, existingIndex);
                                } else {
                                  // 5. If not found, use the full songs list as new playlist
                                  final startIndex = songsFromProvider
                                      .indexWhere((s) => s.id == song.id);
                                  if (startIndex != -1) {
                                    notifier.setPlaylist(
                                        songsFromProvider, startIndex);
                                  }
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isPlaying
                                              ? hexToColor(song.hex_code)
                                                  .withValues(alpha: 0.5)
                                              : Colors.black
                                                  .withValues(alpha: 0.2),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: isPlaying
                                          ? Border.all(
                                              color: hexToColor(song.hex_code),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image.network(
                                              fit: BoxFit.cover,
                                              song.thumbnail_url,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  color: Pallete.cardColor
                                                      .withValues(alpha: 0.7),
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 30,
                                                      height: 30,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            Pallete.whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          // Gradient overlay
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ],
                                                  stops: const [0.6, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Now playing indicator
                                          if (isPlaying)
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      hexToColor(song.hex_code)
                                                          .withValues(
                                                              alpha: 0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.graphic_eq,
                                                      color: Pallete.whiteColor,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Playing",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Pallete.whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          // Song duration
                                          Positioned(
                                            left: 12,
                                            bottom: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    color: Pallete.whiteColor,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "3:45", // Example duration
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Pallete.whiteColor
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Song info with gradient text if playing
                                  SizedBox(
                                    width: 180,
                                    child: isPlaying
                                        ? ShaderMask(
                                            shaderCallback: (bounds) {
                                              return LinearGradient(
                                                colors: [
                                                  Colors.white
                                                      .withValues(alpha: 0.5),
                                                  Colors.white,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ).createShader(bounds);
                                            },
                                            child: Text(
                                              song.song_name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : Text(
                                            song.song_name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 160,
                                        child: Text(
                                          song.artist,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Pallete.subtitleText
                                                .withValues(alpha: 0.8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Icon(
                                      //   Icons.verified,
                                      //   size: 14,
                                      //   color: Colors.blue.withValues(alpha: 0.8),
                                      // ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (error, st) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Couldn't load songs",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Pallete.whiteColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  error.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Pallete.whiteColor
                                        .withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Pallete.cardColor.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  "Try Again",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const LoaderWidget(),
                          const SizedBox(height: 16),
                          Text(
                            "Loading amazing music for you...",
                            style: TextStyle(
                              fontSize: 14,
                              color: Pallete.whiteColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
