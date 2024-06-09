import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/service/tv.dart';

class SeasonDetailScreen extends StatefulWidget {
  final int tvId;
  final int seasonNo;
  const SeasonDetailScreen(
      {super.key, required this.tvId, required this.seasonNo});

  @override
  State<SeasonDetailScreen> createState() => _SeasonDetailScreenState();
}

class _SeasonDetailScreenState extends State<SeasonDetailScreen> {
  Map<String, dynamic> seasonDetail = {};
  List<dynamic> episodes = [];
  DateTime? releaseDate;

  @override
  void initState() {
    handleSeasonDetail();
    super.initState();
  }

  handleSeasonDetail() async {
    dynamic result = await TV().getSeasonDetail(widget.tvId, widget.seasonNo);
    if (mounted) {
      setState(() {
        seasonDetail = result;
        episodes = seasonDetail["episodes"];
        releaseDate = seasonDetail.containsKey("air_date") &&
                seasonDetail["air_date"].toString().isNotEmpty
            ? DateFormat("yyyy-MM-dd").parse(seasonDetail["air_date"])
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Text(
          seasonDetail["name"] ?? "",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: seasonDetail.entries.isEmpty
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
                    padding: padding16,
                    child: Row(
                      children: [
                        seasonDetail.containsKey("poster_path") &&
                                seasonDetail["poster_path"] != null
                            ? Flexible(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          "${Config().imageUrl}${Config().posterSize}${seasonDetail["poster_path"]}"),
                                ))
                            : const SizedBox(),
                        Flexible(
                          flex: 3,
                          child: Container(
                            padding: padding8,
                            child: Text(
                              seasonDetail["overview"],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                      padding: padding16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: episodes.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> episode = episodes[index];
                        DateTime? airDate = episode["air_date"] != null
                            ? DateFormat("yyyy-MM-dd")
                                .parse(episode["air_date"])
                            : null;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          tileColor: Theme.of(context).colorScheme.surfaceTint,
                          leading: Text(
                            episode["episode_number"].toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          title: Text(
                            episode["name"],
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: airDate != null
                                      ? Text(
                                          DateFormat('dd MMMM yyyy')
                                              .format(airDate),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      : const SizedBox()),
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    episode["overview"],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Padding(padding: padding8);
                      }),
                ],
              ),
            ),
    );
  }
}
