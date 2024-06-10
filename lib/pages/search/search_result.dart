import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/models/search_result_model.dart';
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
  MovieSearchResults? movieResults;
  TVSearchResults? tvResults;
  final _debouncer = Debouncer();

  @override
  void initState() {
    searchController.text = widget.searchQuery;

    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {
        activeTabIndex = tabController.index;
      });
    });
    handleSearch(1);
    super.initState();
  }

  void handleSearch(int page, [String? query]) async {
    _debouncer.debounce(
        duration: const Duration(milliseconds: 750),
        onDebounce: () async {
          setState(() {
            movieResults = null;
            tvResults = null;
          });
          String? countryCode = Prefs().preferences.getString("region");
          String finalQuery = query ?? widget.searchQuery;
          var movieResponse = await Search()
              .getSearchMovie(finalQuery, page, countryCode ?? "");
          var tvResponse =
              await Search().getSearchTV(finalQuery, page, countryCode ?? "");
          if (mounted) {
            setState(() {
              movieResults = MovieSearchResults.fromJson(movieResponse);
              tvResults = TVSearchResults.fromJson(tvResponse);
            });
          }
        });
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
            movieResults == null
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
                          itemCount: movieResults!.searchResult.length,
                          itemBuilder: (context, index) {
                            MovieSearchResult result =
                                movieResults!.searchResult[index];
                            int page = movieResults!.page;

                            if (index < 5 && page == 1) {
                              return result.backdropPath.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              colorFilter: ColorFilter.mode(
                                                  Colors.black.withAlpha(125),
                                                  BlendMode.srcOver),
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  result.backdropPath)),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 16, 0, 16),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: movieResultItem(result, context),
                                    )
                                  : movieResultItem(result, context);
                            }
                            return movieResultItem(result, context);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: movieResults!.page != 1
                                    ? () {
                                        handleSearch(movieResults!.page - 1);
                                      }
                                    : null,
                                icon: Icon(
                                  FontAwesomeIcons.chevronLeft,
                                  color: movieResults!.page != 1
                                      ? Colors.white
                                      : Colors.white.withAlpha(75),
                                )),
                            Text(
                              "Page ${movieResults!.page}/${movieResults!.totalPages}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            IconButton(
                                onPressed: movieResults!.page <
                                        movieResults!.totalPages
                                    ? () {
                                        handleSearch(movieResults!.page + 1);
                                      }
                                    : null,
                                icon: Icon(
                                  FontAwesomeIcons.chevronRight,
                                  color: movieResults!.page <
                                          movieResults!.totalPages
                                      ? Colors.white
                                      : Colors.white.withAlpha(75),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
            tvResults == null
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
                          itemCount: tvResults!.searchResult.length,
                          itemBuilder: (context, index) {
                            TVSearchResult item =
                                tvResults!.searchResult[index];
                            int page = tvResults!.page;
                            if (index < 5 && page == 1) {
                              return item.backdropPath.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              colorFilter: ColorFilter.mode(
                                                  Colors.black.withAlpha(125),
                                                  BlendMode.srcOver),
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  item.backdropPath)),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 16, 0, 16),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: tvResultItem(item, context),
                                    )
                                  : tvResultItem(item, context);
                            }
                            return tvResultItem(item, context);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: tvResults!.page != 1
                                    ? () {
                                        handleSearch(tvResults!.page - 1);
                                      }
                                    : null,
                                icon: Icon(
                                  FontAwesomeIcons.chevronLeft,
                                  color: tvResults!.page != 1
                                      ? Colors.white
                                      : Colors.white.withAlpha(75),
                                )),
                            Text(
                              "Page ${tvResults!.page}/${tvResults!.totalPages}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            IconButton(
                                onPressed:
                                    tvResults!.page < tvResults!.totalPages
                                        ? () {
                                            handleSearch(tvResults!.page + 1);
                                          }
                                        : null,
                                icon: Icon(
                                  FontAwesomeIcons.chevronRight,
                                  color: tvResults!.page < tvResults!.totalPages
                                      ? Colors.white
                                      : Colors.white.withAlpha(75),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
          ],
        ));
  }

  ListTile movieResultItem(MovieSearchResult item, BuildContext context) {
    return ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movieId: item.id),
            ),
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.releaseDate != null
                  ? "${item.title} (${item.releaseDate!.year})"
                  : item.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            item.originalTitle != item.title
                ? Text(
                    item.originalTitle,
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                : const SizedBox(),
          ],
        ));
  }

  ListTile tvResultItem(TVSearchResult item, BuildContext context) {
    return ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TVDetailScreen(tvId: item.id),
            ),
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.firstAirDate != null
                  ? "${item.name} (${item.firstAirDate!.year})"
                  : item.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            item.originalName != item.name
                ? Text(
                    item.originalName,
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                : const SizedBox(),
          ],
        ));
  }
}
