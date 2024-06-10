import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/models/certification_model.dart';
import 'package:wheretowatch/models/production_model.dart';
import 'package:wheretowatch/models/watch_provider_model.dart';

class MovieDetail {
  final int id;
  final String title;
  final String originalTitle;
  final String tagline;
  final String overview;
  final DateTime? releaseDate;
  final String backdropPath;
  final String posterPath;
  final List<dynamic> genreList;
  final int runtime;
  final int budget;
  final int revenue;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<Cast> castList;
  final List<Crew> crewList;
  final double voteAverage;
  final String status;
  final WatchProviders watchProviders;
  final Certification? certification;

  MovieDetail(
      this.id,
      this.title,
      this.originalTitle,
      this.tagline,
      this.releaseDate,
      this.backdropPath,
      this.genreList,
      this.runtime,
      this.budget,
      this.revenue,
      this.voteAverage,
      this.status,
      this.watchProviders,
      this.certification,
      this.posterPath,
      this.overview,
      this.productionCompanies,
      this.productionCountries,
      this.castList,
      this.crewList);

  MovieDetail.fromJson(Map<String, dynamic> json, String countryCode)
      : id = json["id"],
        title = json["title"],
        originalTitle = json["original_title"],
        tagline = json["tagline"],
        overview = json["overview"],
        releaseDate = json.containsKey("release_date") &&
                json["release_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(json["release_date"])
            : null,
        backdropPath = json.containsKey("backdrop_path") &&
                json["backdrop_path"] != null
            ? "${Config().imageUrl}${Config().backdropSize}${json["backdrop_path"]}"
            : "",
        posterPath = json.containsKey("poster_path") &&
                json["poster_path"] != null
            ? "${Config().imageUrl}${Config().backdropSize}${json["poster_path"]}"
            : "",
        genreList =
            json["genres"].map((genre) => genre["name"] as String).toList(),
        runtime = json["runtime"],
        budget = json["budget"],
        revenue = json["revenue"],
        productionCompanies = List<ProductionCompany>.from(
            json["production_companies"]
                .map((x) => ProductionCompany.fromJson(x))),
        productionCountries = List<ProductionCountry>.from(
            json["production_countries"]
                .map((x) => ProductionCountry.fromJson(x))),
        castList = List<Cast>.from(
            json["credits"]["cast"].map((x) => Cast.fromJson(x))),
        crewList = List<Crew>.from(
            json["credits"]["crew"].map((x) => Crew.fromJson(x))),
        voteAverage = json["vote_average"],
        status = json["status"],
        watchProviders = WatchProviders.fromJson(
            json["watch/providers"]["results"], countryCode),
        certification =
            _getCertification(json["releases"]["countries"], countryCode);

  static _getCertification(List<dynamic> release, String countryCode) {
    Map<String, dynamic>? releaseData = release.firstWhere(
        (json) => json["iso_3166_1"] == countryCode,
        orElse: () => null);
    if (releaseData != null &&
        releaseData["certification"].toString().isNotEmpty) {
      return Certification.fromJson(releaseData);
    }
    Map<String, dynamic>? usReleaseData = release
        .firstWhere((json) => json["iso_3166_1"] == "US", orElse: () => null);
    if (usReleaseData != null &&
        usReleaseData["certification"].toString().isNotEmpty) {
      return Certification.fromJson(usReleaseData);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "original_title": originalTitle,
        "release_date": releaseDate,
        "backdrop_path": backdropPath
      };
}
