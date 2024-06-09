import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/pages/tv/cast.dart';
import 'package:wheretowatch/pages/tv/common.dart';
import 'package:wheretowatch/pages/tv/crew.dart';
import 'package:wheretowatch/pages/settings/settings.dart';
import 'package:wheretowatch/pages/tv/season_detail.dart';
import 'package:wheretowatch/service/tv.dart';

class TVDetailScreen extends StatefulWidget {
  final int tvId;
  const TVDetailScreen({super.key, required this.tvId});

  @override
  State<TVDetailScreen> createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  Map<String, dynamic> tvDetail = {};
  String? _countryCode;
  String? _countryName;
  String? watchLink;

  DateTime? releaseDate;
  String genreNameList = "";
  String certification = "";

  List<dynamic> streamingServiceList = [[], [], [], []];
  late TabController _tabController;
  int activeTabIndex = 0;
  List<Widget> tabs = const [
    Tab(
      text: "Subscription",
    ),
    Tab(
      text: "Buy",
    ),
    Tab(
      text: "Rent",
    ),
    Tab(
      text: "Ad-supported",
    ),
  ];

  List<dynamic> seasons = [];
  int runtime = 0;

  List<dynamic> cast = [];
  List<dynamic> crew = [];
  List<dynamic> mainCrew = [];

  List<dynamic> productionCompanies = [];
  List<dynamic> productionCountries = [];

  String budget = "";
  String revenue = "";

  @override
  void initState() {
    handleMovieDetail();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  handleMovieDetail() async {
    dynamic result = await TV().getTVDetail(widget.tvId);
    dynamic countryCode = Prefs().preferences.getString("region");
    dynamic countryName = Prefs().preferences.getString("region_name");
    if (mounted) {
      setState(() {
        tvDetail = result;

        releaseDate = tvDetail.containsKey("first_air_date") &&
                tvDetail["first_air_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(tvDetail["first_air_date"])
            : null;

        List<dynamic> genres =
            tvDetail.containsKey("genres") && tvDetail["genres"] != null
                ? tvDetail["genres"]
                : [];
        List<String> genreNames = genres.isNotEmpty
            ? genres.map((genre) => genre["name"] as String).toList()
            : [];
        genreNameList = genreNames.isNotEmpty ? genreNames.join(', ') : "";

        _countryCode = countryCode;
        _countryName = countryName;
        if (tvDetail["watch/providers"]["results"].containsKey(countryCode)) {
          Map<String, dynamic> watchProviders =
              tvDetail["watch/providers"]["results"][countryCode];
          List<dynamic> adStreaming =
              watchProviders.containsKey("ads") ? watchProviders["ads"] : [];
          List<dynamic> buyStreaming =
              watchProviders.containsKey("buy") ? watchProviders["buy"] : [];
          List<dynamic> flatrateStreaming =
              watchProviders.containsKey("flatrate")
                  ? watchProviders["flatrate"]
                  : [];
          List<dynamic> rentStreaming =
              watchProviders.containsKey("rent") ? watchProviders["rent"] : [];
          streamingServiceList = [
            flatrateStreaming,
            buyStreaming,
            rentStreaming,
            adStreaming
          ];
        }
        _tabController =
            TabController(length: streamingServiceList.length, vsync: this);
        _tabController.addListener(() {
          setState(() {
            activeTabIndex = _tabController.index;
          });
        });

        if (tvDetail["credits"].containsKey("cast")) {
          cast = tvDetail["credits"]["cast"];
        }
        if (tvDetail["credits"].containsKey("crew")) {
          crew = tvDetail["credits"]["crew"];
          List<dynamic> producers =
              crew.where((item) => item["job"] == "Producer").toList();
          List<dynamic> directors =
              crew.where((item) => item["job"] == "Director").toList();
          List<dynamic> writers = crew
              .where((item) =>
                  item["job"] == "Screenplay" || item["job"] == "Writer")
              .toList();
          mainCrew = [...directors, ...producers, ...writers];
        }

        seasons = tvDetail["seasons"];
        runtime = tvDetail["episode_run_time"].length > 0
            ? tvDetail["episode_run_time"][0]
            : 0;

        productionCompanies = tvDetail["production_companies"];
        productionCountries = tvDetail["production_countries"];

        if (tvDetail.containsKey("budget") && tvDetail["budget"] != null) {
          budget =
              CurrencyFormatter.format(tvDetail["budget"], CurrencyFormat.usd);
        }
        if (tvDetail.containsKey("revenue") && tvDetail["revenue"] != null) {
          revenue =
              CurrencyFormatter.format(tvDetail["revenue"], CurrencyFormat.usd);
        }
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.position.pixels == 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: _isScrolled
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
            : null,
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
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: tvDetail.entries.isEmpty
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                child: Config().loadingIndicator,
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    padding: padding16,
                    decoration: tvDetail["backdrop_path"] != null
                        ? BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(125),
                                    BlendMode.srcOver),
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Config().imageUrl}${Config().backdropSize}${tvDetail["backdrop_path"]}")))
                        : const BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          releaseDate != null
                              ? "${tvDetail["name"]} (${releaseDate!.year})"
                              : "${tvDetail["name"]}",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        tvDetail["name"] != tvDetail["original_name"]
                            ? Text(
                                tvDetail["original_name"],
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                  Container(
                      padding: padding16,
                      child: Text(
                        tvDetail["tagline"].isNotEmpty
                            ? "\"${tvDetail["tagline"]}\""
                            : "",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(fontStyle: FontStyle.italic),
                      )),
                  Container(
                    padding: padding16,
                    child: Row(
                      children: [
                        tvDetail.containsKey("poster_path") &&
                                tvDetail["poster_path"] != null
                            ? Flexible(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          "${Config().imageUrl}${Config().posterSize}${tvDetail["poster_path"]}"),
                                ))
                            : const SizedBox(),
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              iconWithText(context, FontAwesomeIcons.star,
                                  "${double.parse((tvDetail["vote_average"]).toStringAsFixed(2))} (TMDB)"),
                              iconWithText(
                                  context,
                                  FontAwesomeIcons.calendarCheck,
                                  releaseDate != null
                                      ? "${tvDetail["status"]}\nfirst aired ${DateFormat('d MMMM y').format(releaseDate!)}"
                                      : tvDetail["status"]),
                              runtime != 0
                                  ? iconWithText(
                                      context,
                                      FontAwesomeIcons.clock,
                                      "$runtime minutes per episode")
                                  : const SizedBox(),
                              iconWithText(context, FontAwesomeIcons.film,
                                  genreNameList),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: padding16,
                      child: Column(
                        children: [
                          Text(
                            _countryName != null
                                ? "Where to Watch in $_countryName"
                                : "Where to Watch",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Powered by JustWatch",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      )),
                  Container(
                      padding: padding16,
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        labelColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        unselectedLabelColor: Colors.white,
                        indicatorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        dividerHeight: 0,
                        tabs: tabs,
                      )),
                  Container(
                    padding: padding16,
                    child: streamingServiceList.isNotEmpty
                        ? GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                streamingServiceList[activeTabIndex].length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.8,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8),
                            itemBuilder: (context, index) {
                              return streamingServiceItem(context,
                                  streamingServiceList[activeTabIndex][index]);
                            })
                        : const SizedBox(),
                  ),
                  Container(
                      padding: padding16,
                      child: Text("Seasons",
                          style: Theme.of(context).textTheme.titleMedium)),
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    padding: padding16,
                    child: ListView.builder(
                      itemCount: seasons.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return seasonItem(context, tvDetail, seasons[index]);
                      },
                    ),
                  ),
                  Container(
                      padding: padding16,
                      child: Text("Overview",
                          style: Theme.of(context).textTheme.titleMedium)),
                  Container(
                      padding: padding16,
                      child: Text(
                        tvDetail["overview"].isNotEmpty
                            ? "${tvDetail["overview"]}"
                            : "",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                  Container(
                      padding: padding16,
                      child: Text("Production",
                          style: Theme.of(context).textTheme.titleMedium)),
                  Container(
                      padding: padding16,
                      child: Text("Cast",
                          style: Theme.of(context).textTheme.titleSmall)),
                  Container(
                    height: MediaQuery.of(context).size.height / 5,
                    padding: padding16,
                    child: ListView.builder(
                      itemCount: cast.length <= 10 ? cast.length + 1 : 11,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        bool isLastItem =
                            (index == (cast.length <= 10 ? cast.length : 10));
                        if (isLastItem) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieCastScreen(cast: cast),
                                ),
                              );
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height / 5,
                              width: MediaQuery.of(context).size.width / 4,
                              margin: const EdgeInsets.only(right: 8),
                              padding: padding4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  "View all cast...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return castItem(context, cast[index]);
                        }
                      },
                    ),
                  ),
                  Container(
                      padding: padding16,
                      child: Text("Crew",
                          style: Theme.of(context).textTheme.titleSmall)),
                  Container(
                    height: MediaQuery.of(context).size.height / 5,
                    padding: padding16,
                    child: ListView.builder(
                      itemCount:
                          mainCrew.length <= 10 ? mainCrew.length + 1 : 11,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        bool isLastItem = (index ==
                            (mainCrew.length <= 10 ? mainCrew.length : 10));
                        if (isLastItem) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieCrewScreen(crew: crew),
                                ),
                              );
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height / 5,
                              width: MediaQuery.of(context).size.width / 4,
                              margin: const EdgeInsets.only(right: 8),
                              padding: padding4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  "View all crew...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return crewItem(context, mainCrew[index]);
                        }
                      },
                    ),
                  ),
                  Container(
                      padding: padding16,
                      child: Text("Details",
                          style: Theme.of(context).textTheme.titleSmall)),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        productionCompanies.length > 1
                            ? "Production Companies"
                            : "Production Company",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: productionCompanies.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> company =
                            productionCompanies[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                          child: Row(
                            children: [
                              company["logo_path"] != null
                                  ? Flexible(
                                      flex: 1,
                                      child: Container(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                                width: 64,
                                                imageUrl:
                                                    "${Config().imageUrl}${Config().logoSize}${company["logo_path"]}"),
                                          )),
                                    )
                                  : const SizedBox(),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  company["name"],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        productionCompanies.length > 1
                            ? "Production Countries"
                            : "Production Country",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: productionCountries.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> country =
                            productionCountries[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                          child: Text(
                            country["name"],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        "Budget",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                      child: Text(
                        budget,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        "Revenue",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                      child: Text(
                        revenue,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
