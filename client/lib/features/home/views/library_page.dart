import 'dart:developer';

import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/music_theme.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/views/upload_songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final screenSize = MediaQuery.of(context).size;

    return MusicThemeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Your Favorites',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Pallete.cardColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Pallete.whiteColor,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: currentSong != null
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Color(int.parse(
                              '0xFF${currentSong.hex_code.substring(1)}'))
                          .withValues(alpha: 0.4),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                )
              : BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Pallete.cardColor.withValues(alpha: 0.3),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
          child: ref.watch(getAllFavSongsProvider).when(
                data: (songs) {
                  // log(songs.toString());

                  if (songs.isEmpty) {
                    return _buildEmptyFavorites(context);
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats row
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Pallete.cardColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Pallete.whiteColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.favorite,
                                value: songs.length.toString(),
                                label: 'Favorites',
                                iconColor: Colors.red.shade300,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color:
                                    Pallete.whiteColor.withValues(alpha: 0.2),
                              ),
                              _buildStatItem(
                                icon: Icons.access_time,
                                value:
                                    '${songs.length * 3}:${songs.length * 15}',
                                label: 'Total Time',
                                iconColor: Colors.amber.shade300,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color:
                                    Pallete.whiteColor.withValues(alpha: 0.2),
                              ),
                              _buildStatItem(
                                icon: Icons.person_outline,
                                value: '${(songs.length / 2).ceil()}',
                                label: 'Artists',
                                iconColor: Colors.blue.shade300,
                              ),
                            ],
                          ),
                        ),

                        // Favorites & Actions row
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4.0, right: 4.0, bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'My Favorites',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Pallete.whiteColor
                                          .withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Pallete.cardColor
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.shuffle,
                                      size: 18,
                                      color: Pallete.whiteColor
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Pallete.cardColor
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 18,
                                      color: Pallete.whiteColor
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Favorites List
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: songs.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == songs.length) {
                                return _buildUploadTile(context);
                              }

                              final song = songs[index];
                              final isPlaying = currentSong != null &&
                                  currentSong.id == song.id;

                              return GestureDetector(
                                onTap: () {
                                  final notifier = ref.read(
                                      currentSongNotifierProvider.notifier);
                                  notifier.setPlaylist(songs, index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isPlaying
                                        ? Color(int.parse(
                                                '0xFF${song.hex_code.substring(1)}'))
                                            .withValues(alpha: 0.3)
                                        : Pallete.cardColor
                                            .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: isPlaying
                                        ? Border.all(
                                            color: Color(int.parse(
                                                    '0xFF${song.hex_code.substring(1)}'))
                                                .withValues(alpha: 0.6),
                                            width: 1.5,
                                          )
                                        : Border.all(
                                            color: Pallete.whiteColor
                                                .withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isPlaying
                                            ? Color(int.parse(
                                                    '0xFF${song.hex_code.substring(1)}'))
                                                .withValues(alpha: 0.3)
                                            : Colors.black
                                                .withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Song thumbnail with play indicator
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Hero(
                                            tag: 'fav-thumbnail-${song.id}',
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  song.thumbnail_url,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      color: Pallete.cardColor
                                                          .withValues(
                                                              alpha: 0.7),
                                                      child: const Center(
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Pallete
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isPlaying)
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.pause,
                                                color: Pallete.whiteColor,
                                                size: 28,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),

                                      // Song info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.song_name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isPlaying
                                                    ? Color(int.parse(
                                                            '0xFF${song.hex_code.substring(1)}'))
                                                        .withValues(alpha: 0.9)
                                                    : Pallete.whiteColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person,
                                                  size: 14,
                                                  color: Pallete.subtitleText,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  song.artist,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Pallete.subtitleText,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Pallete.cardColor
                                                        .withValues(alpha: 0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.headphones,
                                                        size: 12,
                                                        color: Pallete
                                                            .whiteColor
                                                            .withValues(
                                                                alpha: 0.7),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "${(index + 1) * 10}K",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Pallete
                                                              .whiteColor
                                                              .withValues(
                                                                  alpha: 0.7),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Pallete.cardColor
                                                        .withValues(alpha: 0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    "3:${45 + index}",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Pallete.whiteColor
                                                          .withValues(
                                                              alpha: 0.7),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Actions
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            color: Colors.red.shade400,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (error, st) {
                  return Center(
                    child: Container(
                      width: screenSize.width * 0.85,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Pallete.cardColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: $error',
                            style: TextStyle(
                              fontSize: 14,
                              color: Pallete.whiteColor.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallete.cardColor,
                              foregroundColor: Pallete.whiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoaderWidget(),
                      SizedBox(height: 16),
                      Text(
                        'Loading your favorites...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Pallete.cardColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.red.shade300,
                      Colors.pink.shade300,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Favorite Songs Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start adding songs to your favorites to see them here.',
              style: TextStyle(
                fontSize: 16,
                color: Pallete.whiteColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // // Discover music button
            // GestureDetector(
            //   onTap: () {

            //   },
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.blue.shade500.withValues(alpha: 0.7),
            //       borderRadius: BorderRadius.circular(16),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.blue.shade500.withValues(alpha: 0.3),
            //           blurRadius: 12,
            //           offset: const Offset(0, 6),
            //         ),
            //       ],
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         const Icon(
            //           Icons.explore,
            //           color: Pallete.whiteColor,
            //           size: 24,
            //         ),
            //         const SizedBox(width: 12),
            //         const Text(
            //           'Discover Music',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //             color: Pallete.whiteColor,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),

            // Upload option
            _buildUploadOption(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => UploadSongsPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Pallete.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Pallete.whiteColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              color: Pallete.whiteColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Upload New Song',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Pallete.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => UploadSongsPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade800.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.shade400.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade400.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Pallete.whiteColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Upload New Song',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Pallete.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Pallete.whiteColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Pallete.whiteColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
