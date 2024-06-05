import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/component.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/pages/settings/settings.dart';
import 'package:wheretowatch/service/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic> movieDetail = {};
  String? countryCode;
  String? countryName;
  String? watchLink;
  List<dynamic> adStreaming = [];
  List<dynamic> buyStreaming = [];
  List<dynamic> flatrateStreaming = [];
  List<dynamic> rentStreaming = [];

  @override
  void initState() {
    handleMovieDetail();
    super.initState();
  }

  handleMovieDetail() async {
    dynamic result = await Movie().getMovieDetail(widget.movieId);
    dynamic _countryCode = Prefs().preferences.getString("region");
    dynamic _countryName = Prefs().preferences.getString("region_name");
    if (mounted) {
      setState(() {
        movieDetail = result;
        countryCode = _countryCode;
        countryName = _countryName;
        if (movieDetail["watch/providers"]["results"]
            .containsKey(countryCode)) {
          Map<String, dynamic> watchProviders =
              movieDetail["watch/providers"]["results"][countryCode];
          adStreaming =
              watchProviders.containsKey("ads") ? watchProviders["ads"] : [];
          buyStreaming =
              watchProviders.containsKey("buy") ? watchProviders["buy"] : [];
          flatrateStreaming = watchProviders.containsKey("flatrate")
              ? watchProviders["flatrate"]
              : [];
          rentStreaming =
              watchProviders.containsKey("rent") ? watchProviders["rent"] : [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? releaseDate = movieDetail.containsKey("release_date") &&
            movieDetail["release_date"].toString().isNotEmpty
        ? DateFormat("yyyy-MM-dd").parse(movieDetail["release_date"])
        : null;

    List<dynamic> genres =
        movieDetail.containsKey("genres") && movieDetail["genres"] != null
            ? movieDetail["genres"]
            : [];
    List<String> genreNames = genres.isNotEmpty
        ? genres.map((genre) => genre["name"] as String).toList()
        : [];
    String genreNameList = genreNames.isNotEmpty ? genreNames.join(', ') : "";

    List<dynamic> releases = movieDetail.containsKey("releases") &&
            movieDetail["releases"]["countries"] != null
        ? movieDetail["releases"]["countries"]
        : [];
    String certification = "";
    releases.forEach((item) {
      if (item["iso_3166_1"] == countryCode && item["certification"] != "") {
        certification = item["certification"];
      } else {
        if (item["iso_3166_1"] == "US") {
          certification = item["certification"];
        }
      }
    });

    inspect(adStreaming);
    inspect(buyStreaming);
    inspect(flatrateStreaming);
    inspect(rentStreaming);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(FontAwesomeIcons.gear))
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: movieDetail.entries.isEmpty
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                child: Config().loadingIndicator,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    padding: const EdgeInsets.all(16),
                    decoration: movieDetail["backdrop_path"] != null
                        ? BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(125),
                                    BlendMode.srcOver),
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Config().imageUrl}${Config().backdropSize}${movieDetail["backdrop_path"]}")))
                        : const BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          releaseDate != null
                              ? "${movieDetail["title"]} (${releaseDate.year})"
                              : "${movieDetail["title"]}",
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        movieDetail["title"] != movieDetail["original_title"]
                            ? Text(
                                movieDetail["original_title"],
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        movieDetail["tagline"].isNotEmpty
                            ? "\"${movieDetail["tagline"]}\""
                            : "",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(fontStyle: FontStyle.italic),
                      )),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        movieDetail.containsKey("poster_path") &&
                                movieDetail["poster_path"] != null
                            ? Flexible(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          "${Config().imageUrl}${Config().posterSize}${movieDetail["poster_path"]}"),
                                ))
                            : const SizedBox(),
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                margin: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 1.0),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  certification,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              iconWithText(context, FontAwesomeIcons.star,
                                  "${double.parse((movieDetail["vote_average"]).toStringAsFixed(2))} (TMDB)"),
                              iconWithText(
                                  context,
                                  FontAwesomeIcons.calendarCheck,
                                  releaseDate != null
                                      ? "${movieDetail["status"]} ${DateFormat('d MMMM y').format(releaseDate)}"
                                      : movieDetail["status"]),
                              iconWithText(context, FontAwesomeIcons.clock,
                                  "${movieDetail["runtime"]} minutes"),
                              iconWithText(context, FontAwesomeIcons.film,
                                  genreNameList),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          countryName != null
                              ? "Where to Watch in $countryName"
                              : "Where to Watch",
                          style: Theme.of(context).textTheme.titleSmall)),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: flatrateStreaming.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8),
                        itemBuilder: (context, index) {
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                    height: 48,
                                    imageUrl:
                                        "${Config().imageUrl}${Config().logoSize}${flatrateStreaming[index]["logo_path"]}"),
                                /* Image.network(
                                    height: 48,
                                    ), */
                                Text(
                                  flatrateStreaming[index]["provider_name"],
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  Container(
                      padding: const EdgeInsets.all(16),
                      child: Text("Details",
                          style: Theme.of(context).textTheme.titleSmall)),
                  Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        movieDetail["overview"].isNotEmpty
                            ? "${movieDetail["overview"]}"
                            : "",
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                ],
              ),
            ),
    );
  }
}
