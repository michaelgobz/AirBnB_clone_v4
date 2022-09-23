import 'dart:convert';

import 'package:http/http.dart';
import 'package:kin_music_player_app/constants.dart';
import 'package:kin_music_player_app/services/network/model/album.dart';
import 'package:kin_music_player_app/services/network/model/artist.dart';
import 'package:kin_music_player_app/services/network/model/genre.dart';
import 'package:kin_music_player_app/services/network/model/music.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicApiService {
  // get new tracks
  Future getMusic(apiEndPoint) async {
    try {
      Response response = await get(Uri.parse("$kinMusicBaseUrl$apiEndPoint"));

      if (response.statusCode == 200) {
        final item = json.decode(response.body) as List;

        List<Music> music = item.map((value) => Music.fromJson(value)).toList();

        return music;
      } else {}
    } catch (e) {
      print("@music_service getMusic $e");
    }
    return [];
  }

  // albums
  Future getAlbums(apiEndPoint) async {
    try {
      Response response = await get(Uri.parse("$kinMusicBaseUrl$apiEndPoint"));
      if (response.statusCode == 200) {
        final item = json.decode(response.body) as List;

        List<Album> albums = item.map((value) {
          return Album.fromJson(value);
        }).toList();

        return albums;
      } else {}
    } catch (e) {
      print("@music_service -> getAlbums error - $e");
    }
    return [];
  }

  // get artists
  Future getArtists(apiEndPoint) async {
    try {
      Response response = await get(Uri.parse("$kinMusicBaseUrl$apiEndPoint"));

      if (response.statusCode == 200) {
        final item = json.decode(response.body) as List;

        item.forEach((artist) {
          artist['Albums'].forEach((album) {
            List allAlbums = artist['Tracks']
                .where((track) =>
                    track['album_id'].toString() == album['id'].toString())
                .toList();

            album['Tracks'] = allAlbums;
          });
        });

        List<Artist> artists = item.map((value) {
          return Artist.fromJson(value);
        }).toList();

        return artists;
      }
    } catch (e) {
      print("@music_service -> getArtists error - $e");
    }
    return [];
  }

  // ignore: slash_for_doc_comments
  /**
   * ==================================
   * GENRE METHODS
   * ==================================
   */

  // get list of all available genres
  Future<List<Genre>> getGenres(apiEndPoint) async {
    try {
      Response response = await get(Uri.parse("$kinMusicBaseUrl/$apiEndPoint"));
      if (response.statusCode == 200) {
        final item = json.decode(response.body) as List;

        List<Genre> genres = item.map((value) {
          return Genre.fromJson(value);
        }).toList();
        return genres;
      }
    } catch (e) {
      print("@music_service -> getGenres error $e");
    }
    return [];
  }

  // get list of all available genres
  Future<List<Music>> getMusicByGenreID({
    required String apiEndPoint,
    required String genreId,
  }) async {
    List<Music> tracksUnderGenre = [];
    try {
      // get user Id
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString("id") ?? "";

      // make api call
      Response response = await get(Uri.parse(
          "$kinMusicBaseUrl$apiEndPoint?userId=$uid&genreId=$genreId"));

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as List;

        tracksUnderGenre = result.map((track) {
          return Music.fromJson(track);
        }).toList();
      }
    } catch (e) {
      print("@music_service -> getMusicByGenreID error $e");
    }
    return tracksUnderGenre;
  }

  Future addPopularCount(
      {required String track_id, required String user_id}) async {
    var data = {"user_id": user_id, "track_id": track_id};
    Response response = await post(
      Uri.parse("${kAnalyticsBaseUrl}/view_count"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }
}
