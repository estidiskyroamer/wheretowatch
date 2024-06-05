import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/pages/movie/movie_detail.dart';
import 'package:wheretowatch/service/search.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  TextEditingController searchController = TextEditingController();
  dynamic result;

  @override
  void initState() {
    searchController.text = widget.searchQuery;
    handleSearch(1);
    super.initState();
  }

  void handleSearch(int page, [String? query]) async {
    setState(() {
      result = null;
    });
    String finalQuery = query ?? widget.searchQuery;
    var response = await Search().getSearchMovie(finalQuery, page);
    if (mounted) {
      setState(() {
        result = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: TextField(
          controller: searchController,
          style: Theme.of(context).textTheme.bodySmall,
          onChanged: (value) {
            if (value.isNotEmpty) {
              handleSearch(1, value);
            }
          },
        ),
      ),
      body: result == null
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
                    itemCount: result["results"].length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item = result["results"][index];
                      int page = result["page"];
                      DateTime? releaseDate = item.containsKey("release_date") && item["release_date"].toString().isNotEmpty
                          ? DateFormat("yyyy-MM-dd").parse(item["release_date"])
                          : null;
                      if (index < 5 && page == 1) {
                        return item["backdrop_path"] != null
                            ? Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withAlpha(175),
                                            BlendMode.srcOver),
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            "${Config().imageUrl}${Config().backdropSize}${item["backdrop_path"]}")),
                                    borderRadius: BorderRadius.circular(8)),
                                padding:
                                    const EdgeInsets.fromLTRB(0, 16, 0, 16),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: resultItem(item, releaseDate, context),
                              )
                            : resultItem(item, releaseDate, context);
                      }
                      return resultItem(item, releaseDate, context);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: result["page"] != 1
                              ? () {
                                  handleSearch(result["page"] - 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronLeft,
                            color: result["page"] != 1
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          )),
                      Text(
                        "Page ${result["page"]}/${result["total_pages"]}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                          onPressed: result["page"] < result["total_pages"]
                              ? () {
                                  handleSearch(result["page"] + 1);
                                }
                              : null,
                          icon: Icon(
                            FontAwesomeIcons.chevronRight,
                            color: result["page"] < result["total_pages"]
                                ? Colors.white
                                : Colors.white.withAlpha(75),
                          ))
                    ],
                  )
                ],
              ),
            ),
    );
  }

  ListTile resultItem(item, DateTime? releaseDate, BuildContext context) {
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
          style: Theme.of(context).textTheme.bodySmall,
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
}
