class Country {
  final String countryCode;
  final String countryName;

  Country(this.countryCode, this.countryName);

  Country.fromJson(Map<String, dynamic> json) :
  countryCode = json["iso_3166_1"],
countryName = json["english_name"];

Map<String, dynamic> toJson() => {
        "iso_3166_1": countryCode,
        "english_name": countryName
      };
}