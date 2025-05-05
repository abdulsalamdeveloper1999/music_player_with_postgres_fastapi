// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FavoriteSongModel {
  final String id;
  final String song_id;
  final String user_id;
  FavoriteSongModel({
    required this.id,
    required this.song_id,
    required this.user_id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'song_id': song_id,
      'user_id': user_id,
    };
  }

  factory FavoriteSongModel.fromMap(Map<String, dynamic> map) {
    return FavoriteSongModel(
      id: map['id'] as String,
      song_id: map['song_id'] as String,
      user_id: map['user_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FavoriteSongModel.fromJson(String source) =>
      FavoriteSongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  FavoriteSongModel copyWith({
    String? id,
    String? song_id,
    String? user_id,
  }) {
    return FavoriteSongModel(
      id: id ?? this.id,
      song_id: song_id ?? this.song_id,
      user_id: user_id ?? this.user_id,
    );
  }
}
