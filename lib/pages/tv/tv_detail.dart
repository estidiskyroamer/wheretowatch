import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/models/detail_model.dart';
import 'package:wheretowatch/models/production_model.dart';
import 'package:wheretowatch/models/season_model.dart';
import 'package:wheretowatch/models/watch_provider_model.dart';
import 'package:wheretowatch/pages/common/cast.dart';
import 'package:wheretowatch/pages/common/crew.dart';
import 'package:wheretowatch/pages/tv/common.dart';
import 'package:wheretowatch/pages/settings/settings.dart';
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

  late TVDetail tvDetail;
  String? _countryCode;
  String? _countryName;
  String? watchLink;

  DateTime? releaseDate;
  DateTime? firstAirDate;
  String genreNameList = "";
  String certification = "";
  late WatchProviders watchProviders;

  List<List<WatchProvider>> streamingServiceList = [[], [], [], []];
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

  List<Season> seasons = [];
  int runtime = 0;

  List<Cast> cast = [];
  List<Crew> crew = [];
  List<Crew> mainCrew = [];

  List<ProductionCompany> productionCompanies = [];
  List<ProductionCountry> productionCountries = [];

  bool isLoading = true;

  @override
  void initState() {
    handleTVDetail();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  handleTVDetail() async {
    dynamic result = await TV().getTVDetail(widget.tvId);
    dynamic countryCode = Prefs().preferences.getString("region");
    dynamic countryName = Prefs().preferences.getString("region_name");
    if (mounted) {
      setState(() {
        _countryCode = countryCode;
        _countryName = countryName;

        isLoading = false;

        tvDetail = TVDetail.fromJson(result, _countryCode!);
        firstAirDate = tvDetail.firstAirDate;
        List<dynamic> genres = tvDetail.genreList;
        genreNameList = genres.isNotEmpty ? genres.join(', ') : "";
        watchProviders = tvDetail.watchProviders;
        streamingServiceList = [
          watchProviders.flatrate,
          watchProviders.buy,
          watchProviders.rent,
          watchProviders.ads
        ];

        cast = tvDetail.castList;
        crew = tvDetail.crewList;
        List<Crew> producers =
            crew.where((item) => item.job == "Producer").toList();
        List<Crew> directors =
            crew.where((item) => item.job == "Director").toList();
        List<Crew> writers = crew
            .where((item) => item.job == "Screenplay" || item.job == "Writer")
            .toList();
        mainCrew = [...directors, ...producers, ...writers];
        seasons = tvDetail.seasonList;
        runtime = tvDetail.runtime;

        productionCompanies = tvDetail.productionCompanies;
        productionCountries = tvDetail.productionCountries;

        _tabController =
            TabController(length: streamingServiceList.length, vsync: this);
        _tabController.addListener(() {
          setState(() {
            activeTabIndex = _tabController.index;
          });
        });
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
      body: isLoading
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
                    decoration: tvDetail.backdropPath.isNotEmpty
                        ? BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(125),
                                    BlendMode.srcOver),
                                fit: BoxFit.cover,
                                image: NetworkImage(tvDetail.backdropPath)))
                        : const BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          releaseDate != null
                              ? "${tvDetail.name} (${releaseDate!.year})"
                              : tvDetail.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        tvDetail.name != tvDetail.originalName
                            ? Text(
                                tvDetail.originalName,
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
                        tvDetail.tagline,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(fontStyle: FontStyle.italic),
                      )),
                  Container(
                    padding: padding16,
                    child: Row(
                      children: [
                        tvDetail.posterPath.isNotEmpty
                            ? Flexible(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                      imageUrl: tvDetail.posterPath),
                                ))
                            : const SizedBox(),
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              iconWithText(context, FontAwesomeIcons.star,
                                  "${double.parse((tvDetail.voteAverage).toStringAsFixed(2))} (TMDB)"),
                              iconWithText(
                                  context,
                                  FontAwesomeIcons.calendarCheck,
                                  releaseDate != null
                                      ? "${tvDetail.status}\nfirst aired ${DateFormat('d MMMM y').format(releaseDate!)}"
                                      : tvDetail.status),
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
                              return watchProviderItem(context,
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
                        tvDetail.overview,
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
                                  builder: (context) => CastScreen(cast: cast),
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
                                  builder: (context) => CrewScreen(crew: crew),
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
                        ProductionCompany company = productionCompanies[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                          child: Row(
                            children: [
                              company.logoPath.isNotEmpty
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
                                                imageUrl: company.logoPath),
                                          )),
                                    )
                                  : const SizedBox(),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  company.name,
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
                        ProductionCountry country = productionCountries[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                          child: Text(
                            country.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }),
                ],
              ),
            ),
    );
  }
}
