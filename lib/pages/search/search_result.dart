import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/pages/movie/movie_detail.dart';
import 'package:wheretowatch/pages/tv/tv_detail.dart';
import 'package:wheretowatch/service/search.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  late TabController tabController;
  List<Widget> tabs = const [
    Tab(
      text: "Movie",
    ),
    Tab(
      text: "TV Series",
    ),
  ];
  int activeTabIndex = 0;
  dynamic movieResult;
  dynamic tvResult;

  @override
  void initState() {
    searchController.text = widget.searchQuery;
    handleSearch(1);
    super.initState();
  }

  void handleSearch(int page, [String? query]) async {
    setState(() {
        tabController = TabController(length: tabs.length, vsync: this);
        tabController.addListener(() {
          setState(() {
            activeTabIndex = tabController.index;
          });
        });
      movieResult = null;
      tvResult = null;
    });
    String? countryCode = Prefs().preferences.getString("region");
    String finalQuery = query ?? widget.searchQuery;
    var movieResponse =
        await Search().getSearchMovie(finalQuery, page, countryCode ?? "");
    var tvResponse =
        await Search().getSearchTV(finalQuery, page, countryCode ?? "");
    if (mounted) {
      setState(() {
        movieResult = movieResponse;
        tvResult = tvResponse;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: TextField(
          controller: searchController,
          style: Theme.of(context).textTheme.bodyMedium,
          onChanged: (value) {
            if (value.isNotEmpty) {
              handleSearch(1, value);
            }
          },
        ),
        bottom: TabBar(
                    tabs: tabs,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    labelColor: Theme.of(context).colorScheme.inversePrimary,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: Theme.of(context).colorScheme.inversePrimary,
                    dividerHeight: 0,
                    controller: tabController,
                  ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
        movieResult == null
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                child: Config().loadingIndicator,
              ),
            )
          : SingleChildScrollView(
            child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: movieResult["results"].length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item = movieResult["results"][index];
                      int page = movieResult["page"];
                      DateTime? releaseDate =
                          item.containsKey("release_date") &&
                                  item["release_date"].toString().isNotEmpty
                              ? DateFormat("yyyy-MM-dd")
                                  .parse(item["release_date"])
                              : null;
                      if (index < 5 && page == 1) {
                        return item["backdrop_path"] != null
                            ? Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withAlpha(125),
                                            BlendMode.srcOver),
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            "${Config().imageUrl}${Config().backdropSize}${item["backdrop_path"]}")),
                                    borderRadius: BorderRadius.circular(8)),
                                padding:
                                    const EdgeInsets.fromLTRB(0, 16, 0, 16),
                                margin: const EdgeInsets.only(bottom: 12),
                                child:
                                    movieResultItem(item, releaseDate, context),
                              )
                            : movieResultItem(item, releaseDate, context);
                      }
                      return movieResultItem(item, releaseDate, context);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: movieResult["page"] != 1
                              ? () {
                                  handleSearch(movieResult["page"] - 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronLeft,
                            color: movieResult["page"] != 1
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          )),
                      Text(
                        "Page ${movieResult["page"]}/${movieResult["total_pages"]}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                          onPressed: movieResult["page"] < movieResult["total_pages"]
                              ? () {
                                  handleSearch(movieResult["page"] + 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronRight,
                            color: movieResult["page"] < movieResult["total_pages"]
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          ))
                    ],
                  )
                ],
              ),
          ),
            tvResult == null
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                child: Config().loadingIndicator,
              ),
            )
          : SingleChildScrollView(
            child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: tvResult["results"].length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item = tvResult["results"][index];
                      int page = tvResult["page"];
                      DateTime? releaseDate =
                          item.containsKey("first_air_date") &&
                                  item["first_air_date"].toString().isNotEmpty
                              ? DateFormat("yyyy-MM-dd")
                                  .parse(item["first_air_date"])
                              : null;
                      if (index < 5 && page == 1) {
                        return item["backdrop_path"] != null
                            ? Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withAlpha(125),
                                            BlendMode.srcOver),
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            "${Config().imageUrl}${Config().backdropSize}${item["backdrop_path"]}")),
                                    borderRadius: BorderRadius.circular(8)),
                                padding:
                                    const EdgeInsets.fromLTRB(0, 16, 0, 16),
                                margin: const EdgeInsets.only(bottom: 12),
                                child:
                                    tvResultItem(item, releaseDate, context),
                              )
                            : tvResultItem(item, releaseDate, context);
                      }
                      return tvResultItem(item, releaseDate, context);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: tvResult["page"] != 1
                              ? () {
                                  handleSearch(tvResult["page"] - 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronLeft,
                            color: tvResult["page"] != 1
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          )),
                      Text(
                        "Page ${tvResult["page"]}/${tvResult["total_pages"]}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                          onPressed: tvResult["page"] < tvResult["total_pages"]
                              ? () {
                                  handleSearch(tvResult["page"] + 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronRight,
                            color: tvResult["page"] < tvResult["total_pages"]
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          ))
                    ],
                  )
                ],
              ),
          ),
      ],)
    );
  }

  ListTile movieResultItem(item, DateTime? releaseDate, BuildContext context) {
    return ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movieId: item["id"]),
            ),
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              releaseDate != null
                  ? "${item["title"]} (${releaseDate.year})"
                  : "${item["title"]}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            item["original_title"] != item["title"]
                ? Text(
                    item["original_title"],
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                : const SizedBox(),
          ],
        ));
  }

  ListTile tvResultItem(item, DateTime? releaseDate, BuildContext context) {
    return ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TVDetailScreen(tvId: item["id"]),
            ),
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              releaseDate != null
                  ? "${item["name"]} (${releaseDate.year})"
                  : "${item["name"]}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            item["original_name"] != item["name"]
                ? Text(
                    item["original_name"],
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                : const SizedBox(),
          ],
        ));
  }
}
