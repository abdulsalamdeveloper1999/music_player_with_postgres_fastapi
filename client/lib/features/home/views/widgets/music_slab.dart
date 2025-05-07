import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  final VoidCallback? onExpandTap;

  const MusicSlab({
    super.key,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongNotifier = ref.watch(currentSongNotifierProvider);
    final currentSong = ref.watch(currentSongNotifierProvider.notifier);
    final currentUser = ref.watch(currentUserNotifierProvider)?.favorites;

    if (currentSongNotifier == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Pallete.backgroundColor.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                  tag: currentSongNotifier.song_name,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      currentSongNotifier.thumbnail_url.isNotEmpty
                          ? currentSongNotifier.thumbnail_url
                          : 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                      height: 54,
                      width: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Song info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentSongNotifier.song_name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentSongNotifier.artist,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              Row(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          hexToColor(currentSongNotifier.hex_code)
                              .withValues(alpha: 0.3),
                          hexToColor(currentSongNotifier.hex_code),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                          currentSong.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white),
                      onPressed: currentSong.playPause,
                    ),
                  ),
                  Consumer(
                    builder: (_, ref, __) {
                      return IconButton(
                        icon: Icon(
                            currentUser!
                                    .where((fav) =>
                                        fav.song_id == currentSongNotifier.id)
                                    .toList()
                                    .isNotEmpty
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: Colors.white),
                        onPressed: () async {
                          await ref
                              .read(homeViewmodelProvider.notifier)
                              .favoriteSong(currentSongNotifier.id);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less, color: Colors.white),
                    onPressed: onExpandTap,
                  ),
                ],
              ),
            ],
          ),
        ),
        StreamBuilder(
            stream: currentSong.audioPlayer.positionStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }

              final duration = currentSong.audioPlayer.duration;
              final position = snapshot.data;
              double sliderValue = 0.0;
              if (duration != null && position != null) {
                sliderValue = position.inMilliseconds / duration.inMilliseconds;
              }

              return Positioned(
                bottom: 0,
                child: Container(
                  width: sliderValue * (MediaQuery.of(context).size.width - 32),
                  height: 2,
                  color: Pallete.whiteColor,
                ),
              );
            }),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            color: Pallete.inactiveSeekColor,
          ),
        ),
      ],
    );
  }
}
