import 'dart:developer';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/pages/search/search_result.dart';
import 'package:wheretowatch/pages/settings/settings.dart';
import 'package:wheretowatch/service/trending.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer();
  dynamic backdropResults;

  void handleSearch(String query) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 750),
      onDebounce: () async {
        searchController.text = "";
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(searchQuery: query),
          ),
        );
      },
    );
  }

  void handleTrendingMovies() async {
    var response = await Trending().getTrendingMovies();
    if (mounted) {
      setState(() {
        backdropResults = response;
      });
    }
  }

  @override
  void initState() {
    handleTrendingMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic backdrops =
        backdropResults == null ? null : backdropResults["results"];
    int randomNumber =
        backdrops == null ? 0 : Random().nextInt(backdrops.length);
    return Scaffold(
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
            icon: const Icon(FontAwesomeIcons.gear),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      extendBodyBehindAppBar: true,
      body: backdrops == null
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                child: Config().loadingIndicator,
              ),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withAlpha(200),
                      BlendMode.srcATop),
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                      "${Config().imageUrl}${Config().backdropSizeLarge}${backdrops[randomNumber]["backdrop_path"]}"),
                ),
              ),
              child: Column(
                children: [
                  Flexible(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "What do you want to watch?",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Container(
                          padding: padding16,
                          child: TextField(
                            decoration: InputDecoration(
                                hintText:
                                    "e.g. ${backdrops[randomNumber]["title"]}",
                                hintStyle:
                                    Theme.of(context).textTheme.labelMedium),
                            controller: searchController,
                            style: Theme.of(context).textTheme.bodyMedium,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                handleSearch(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: padding16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                              width: 96,
                              image: AssetImage('assets/images/finder.png')),
                          Text(
                            "Where2Watch",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Padding(padding: padding4),
                          Text(
                            "Powered by TMDB and JustWatch",
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
