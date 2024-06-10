class Certification {
  final String countryCode;
  final String certification;

  Certification(this.countryCode, this.certification);

  Certification.fromJson(Map<String, dynamic> json)
      : countryCode = json["iso_3166_1"],
        certification = json["certification"];
}
