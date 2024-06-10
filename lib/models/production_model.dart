import 'package:wheretowatch/common/config.dart';

class ProductionCompany {
  final String logoPath;
  final String name;

  ProductionCompany(this.logoPath, this.name);

  ProductionCompany.fromJson(Map<String, dynamic> json)
      : logoPath = json.containsKey("logo_path") && json["logo_path"] != null
            ? "${Config().imageUrl}${Config().logoSize}${json["logo_path"]}"
            : "",
        name = json["name"];
}

class ProductionCountry {
  final String countryCode;
  final String name;

  ProductionCountry(this.countryCode, this.name);

  ProductionCountry.fromJson(Map<String, dynamic> json)
      : countryCode = json["iso_3166_1"],
        name = json["name"];
}

class Cast {
  final String profilePath;
  final String name;
  final String character;

  Cast(this.profilePath, this.name, this.character);

  Cast.fromJson(Map<String, dynamic> json)
      : profilePath = json.containsKey("profile_path") &&
                json["profile_path"] != null
            ? "${Config().imageUrl}${Config().profileSize}${json["profile_path"]}"
            : "",
        name = json["name"],
        character = json["character"];
}

class Crew {
  final String profilePath;
  final String name;
  final String job;

  Crew(this.profilePath, this.name, this.job);

  Crew.fromJson(Map<String, dynamic> json)
      : profilePath = json.containsKey("profile_path") &&
                json["profile_path"] != null
            ? "${Config().imageUrl}${Config().profileSize}${json["profile_path"]}"
            : "",
        name = json["name"],
        job = json["job"];
}
