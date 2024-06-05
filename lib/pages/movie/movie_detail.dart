import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/service/movie.dart';
import 'package:wheretowatch/service/search.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic> movieDetail = {};

  @override
  void initState() {
    handleMovieDetail();
    super.initState();
  }

  handleMovieDetail() async {
    dynamic result = await Movie().getMovieDetail(widget.movieId);
    if (mounted) {
      setState(() {
        movieDetail = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? releaseDate = movieDetail.containsKey("release_date") &&
            movieDetail["release_date"].toString().isNotEmpty
        ? DateFormat("yyyy-MM-dd").parse(movieDetail["release_date"])
        : null;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
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
                      child: Text(
                        movieDetail["overview"].isNotEmpty
                            ? "${movieDetail["overview"]}"
                            : "",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      )),
                ],
              ),
            ),
    );
  }
}
