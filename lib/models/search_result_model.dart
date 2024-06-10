import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';

class MovieSearchResult {
  final int id;
  final String title;
  final String originalTitle;
  final DateTime? releaseDate;
  final String backdropPath;

  MovieSearchResult(this.id, this.title, this.originalTitle, this.releaseDate,
      this.backdropPath);

  MovieSearchResult.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        originalTitle = json["original_title"],
        releaseDate = json.containsKey("release_date") &&
                json["release_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(json["release_date"])
            : null,
        backdropPath = json.containsKey("backdrop_path") &&
                json["backdrop_path"] != null
            ? "${Config().imageUrl}${Config().backdropSize}${json["backdrop_path"]}"
            : "";

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "original_title": originalTitle,
        "release_date": releaseDate,
        "backdrop_path": backdropPath
      };
}

class MovieSearchResults {
  final int page;
  final int totalPages;
  final List<MovieSearchResult> searchResult;

  MovieSearchResults(this.page, this.totalPages, this.searchResult);

  MovieSearchResults.fromJson(Map<String, dynamic> json)
      : page = json["page"],
        totalPages = json["total_pages"],
        searchResult = List<MovieSearchResult>.from(
            json["results"].map((x) => MovieSearchResult.fromJson(x)));

  Map<String, dynamic> toJson() => {
        "page": page,
        "total_pages": totalPages,
        "results": List<dynamic>.from(searchResult.map((x) => x.toJson()))
      };
}

class TVSearchResult {
  final int id;
  final String name;
  final String originalName;
  final DateTime? firstAirDate;
  final String backdropPath;

  TVSearchResult(this.id, this.name, this.originalName, this.firstAirDate,
      this.backdropPath);

  TVSearchResult.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        originalName = json["original_name"],
        firstAirDate = json.containsKey("first_air_date") &&
                json["first_air_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(json["first_air_date"])
            : null,
        backdropPath = json.containsKey("backdrop_path") &&
                json["backdrop_path"] != null
            ? "${Config().imageUrl}${Config().backdropSize}${json["backdrop_path"]}"
            : "";
}

class TVSearchResults {
  final int page;
  final int totalPages;
  final List<TVSearchResult> searchResult;

  TVSearchResults(this.page, this.totalPages, this.searchResult);

  TVSearchResults.fromJson(Map<String, dynamic> json)
      : page = json["page"],
        totalPages = json["total_pages"],
        searchResult = List<TVSearchResult>.from(
            json["results"].map((x) => TVSearchResult.fromJson(x)));
}
