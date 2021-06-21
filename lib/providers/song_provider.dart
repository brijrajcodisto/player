import 'package:app/models/album.dart';
import 'package:app/models/artist.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/album_provider.dart';
import 'package:app/providers/artist_provider.dart';
import 'package:app/values/parse_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

ParseResult parseSongs(List<dynamic> data) {
  ParseResult result = ParseResult();

  data.forEach((element) {
    result.add(Song.fromJson(element), element['id']);
  });

  return result;
}

class SongProvider with ChangeNotifier {
  late List<Song> _songs;
  late Map<String, Song> _index;

  Future<void> init(BuildContext context, List<dynamic> songData) async {
    ArtistProvider artistProvider =
        Provider.of<ArtistProvider>(context, listen: false);
    AlbumProvider albumProvider =
        Provider.of<AlbumProvider>(context, listen: false);

    ParseResult result = await compute(parseSongs, songData);
    _songs = result.collection.cast();
    _index = result.index.cast();

    _songs.forEach((song) {
      song.artist = artistProvider.byId(song.artistId);
      song.album = albumProvider.byId(song.albumId);
    });
  }

  void initInteractions(BuildContext context, List<dynamic> interactionData) {
    interactionData.forEach((element) {
      Song _song = byId(element['song_id']);
      _song.liked = element['liked'];
      _song.playCount = element['play_count'];
      _song.artist.playCount += _song.playCount;
      _song.album.playCount += _song.playCount;
    });
  }

  List<Song> recentlyAdded({int limit = 6}) {
    List<Song> clone = List<Song>.from(_songs);
    clone.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return clone.sublist(0, limit);
  }

  List<Song> mostPlayed({int limit = 15}) {
    List<Song> clone = List<Song>.from(_songs);
    clone.sort((a, b) => b.playCount.compareTo(a.playCount));
    return clone.sublist(0, limit);
  }

  Song byId(String id) {
    return _index[id]!;
  }

  List<Song> byArtist(Artist artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  List<Song> byAlbum(Album album) {
    return _songs.where((song) => song.album == album).toList();
  }
}