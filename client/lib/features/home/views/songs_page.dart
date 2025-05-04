import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Today',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          ref.watch(getAllSongsProvider).when(data: (songs) {
            // log(songs.toString());
            return SizedBox(
              height: 260,
              child: ListView.builder(
                itemCount: songs.length,
                // scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  final song = songs[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentSongNotifierProvider.notifier)
                          .updateSong(song);
                    },
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                            song.thumbnail_url,
                          ),
                        ),
                        Text(
                          song.song_name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            color: Pallete.subtitleText,
                          ),
                          maxLines: 1,
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          }, error: (error, st) {
            return Text(error.toString());
          }, loading: () {
            return LoaderWidget();
          })
        ],
      ),
    );
  }
}
