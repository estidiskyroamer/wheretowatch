import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';

class Season {
  final String posterPath;
  final String name;
  final int seasonNumber;
  final DateTime? airDate;
  final int episodeCount;

  Season(this.posterPath, this.name, this.airDate, this.episodeCount,
      this.seasonNumber);

  Season.fromJson(Map<String, dynamic> json)
      : posterPath = json.containsKey("poster_path") &&
                json["poster_path"] != null
            ? "${Config().imageUrl}${Config().posterSize}${json["poster_path"]}"
            : "",
        name = json["name"],
        seasonNumber = json["season_number"],
        airDate = json.containsKey("air_date") && json["air_date"] != null
            ? DateFormat("yyyy-MM-dd").parse(json["air_date"])
            : null,
        episodeCount = json["episode_count"];
}

class SeasonDetail {
  final String posterPath;
  final String name;
  final String overview;
  final int seasonNumber;
  final List<Episode> episodes;

  SeasonDetail(this.posterPath, this.name, this.overview, this.seasonNumber,
      this.episodes);

  SeasonDetail.fromJson(Map<String, dynamic> json)
      : posterPath = json.containsKey("poster_path") &&
                json["poster_path"] != null
            ? "${Config().imageUrl}${Config().posterSize}${json["poster_path"]}"
            : "",
        name = json["name"],
        seasonNumber = json["season_number"],
        overview = json["overview"],
        episodes = List<Episode>.from(
            json["episodes"].map((x) => Episode.fromJson(x)));
}

class Episode {
  final String name;
  final String overview;
  final DateTime? airDate;
  final int episodeNumber;
  final int runtime;
  final int seasonNumber;
  final String stillPath;

  Episode(this.name, this.overview, this.airDate, this.episodeNumber,
      this.runtime, this.seasonNumber, this.stillPath);

  Episode.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        overview = json["overview"],
        airDate = json.containsKey("air_date") &&
                json["air_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(json["air_date"])
            : null,
        episodeNumber = json["episode_number"],
        runtime = json["runtime"],
        seasonNumber = json["season_number"],
        stillPath = json.containsKey("still_path") && json["still_path"] != null
            ? "${Config().imageUrl}${Config().stillSize}${json["still_path"]}"
            : "";
}
