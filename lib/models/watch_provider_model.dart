import 'package:wheretowatch/common/config.dart';

class WatchProvider {
  final String logoPath;
  final String providerName;

  WatchProvider(this.logoPath, this.providerName);

  WatchProvider.fromJson(Map<String, dynamic> json)
      : logoPath = json.containsKey("logo_path") && json["logo_path"] != null
            ? "${Config().imageUrl}${Config().logoSize}${json["logo_path"]}"
            : "",
        providerName = json["provider_name"];

  Map<String, dynamic> toJson() =>
      {"logo_path": logoPath, "provider_name": providerName};
}

class WatchProviders {
  final String link;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;
  final List<WatchProvider> flatrate;
  final List<WatchProvider> ads;

  WatchProviders(this.link, this.rent, this.buy, this.flatrate, this.ads);

  WatchProviders.fromJson(Map<String, dynamic> json, String countryCode)
      : link = json.containsKey(countryCode) ? json[countryCode]["link"] : "",
        rent = json.containsKey(countryCode) &&
                json[countryCode].containsKey("rent")
            ? List<WatchProvider>.from(
                json[countryCode]["rent"].map((x) => WatchProvider.fromJson(x)))
            : [],
        buy = json.containsKey(countryCode) &&
                json[countryCode].containsKey("buy")
            ? List<WatchProvider>.from(
                json[countryCode]["buy"].map((x) => WatchProvider.fromJson(x)))
            : [],
        flatrate = json.containsKey(countryCode) &&
                json[countryCode].containsKey("flatrate")
            ? List<WatchProvider>.from(json[countryCode]["flatrate"]
                .map((x) => WatchProvider.fromJson(x)))
            : [],
        ads = json.containsKey(countryCode) &&
                json[countryCode].containsKey("ads")
            ? List<WatchProvider>.from(
                json[countryCode]["ads"].map((x) => WatchProvider.fromJson(x)))
            : [];
}
