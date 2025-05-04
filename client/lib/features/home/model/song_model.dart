import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

class SongModel {
  final String id;
  final String song_name;
  final String thumbnail_url;
  final String song_url;
  final String hex_code;
  final String artist;
  SongModel({
    required this.id,
    required this.song_name,
    required this.thumbnail_url,
    required this.song_url,
    required this.hex_code,
    required this.artist,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'song_name': song_name,
      'thumbnail_url': thumbnail_url,
      'song_url': song_url,
      'hex_code': hex_code,
      'artist': artist,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      song_name: map['song_name'] ?? '',
      thumbnail_url: map['thumbnail_url'] ?? '',
      song_url: map['song_url'] ?? '',
      hex_code: map['hex_code'] ?? '',
      artist: map['artist'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) =>
      SongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SongModel(id: $id, song_name: $song_name, thumbnail_url: $thumbnail_url, song_url: $song_url, hex_code: $hex_code, artist: $artist)';
  }

  SongModel copyWith({
    String? id,
    String? song_name,
    String? thumbnail_url,
    String? song_url,
    String? hex_code,
    String? artist,
  }) {
    return SongModel(
      id: id ?? this.id,
      song_name: song_name ?? this.song_name,
      thumbnail_url: thumbnail_url ?? this.thumbnail_url,
      song_url: song_url ?? this.song_url,
      hex_code: hex_code ?? this.hex_code,
      artist: artist ?? this.artist,
    );
  }
}
