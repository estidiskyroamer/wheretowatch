import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/models/detail_model.dart';
import 'package:wheretowatch/models/production_model.dart';
import 'package:wheretowatch/models/season_model.dart';
import 'package:wheretowatch/models/watch_provider_model.dart';
import 'package:wheretowatch/pages/tv/season_detail.dart';

Widget watchProviderItem(BuildContext context, WatchProvider item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(height: 48, imageUrl: item.logoPath),
      ),
      Container(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          item.providerName,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      )
    ],
  );
}

Widget iconWithText(BuildContext context, IconData iconData, String text) {
  return Container(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Icon(
              iconData,
              size: 14,
              color: Colors.white,
            )),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
      ],
    ),
  );
}

Widget seasonItem(BuildContext context, TVDetail tvItem, Season seasonItem) {
  DateTime? airDate = seasonItem.airDate;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeasonDetailScreen(
                tvId: tvItem.id,
                seasonNo: seasonItem.seasonNumber,
              ),
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width / 3,
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: padding4,
          decoration: seasonItem.posterPath.isEmpty
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      width: 1.5),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(seasonItem.posterPath),
                  ),
                ),
        ),
      ),
      Text(
        airDate != null
            ? "${seasonItem.name} (${airDate.year})"
            : seasonItem.name,
        maxLines: 2,
        overflow: TextOverflow.fade,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        "${seasonItem.episodeCount} episodes",
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

Widget castItem(BuildContext context, Cast item) {
  return Container(
    height: MediaQuery.of(context).size.height / 5,
    width: MediaQuery.of(context).size.width / 4,
    margin: const EdgeInsets.only(right: 8),
    decoration: item.profilePath.isEmpty
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 1.5),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(item.profilePath),
            ),
          ),
    child: Container(
      padding: padding4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.5, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            item.character,
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

Widget crewItem(BuildContext context, Crew item) {
  return Container(
    height: MediaQuery.of(context).size.height / 5,
    width: MediaQuery.of(context).size.width / 4,
    margin: const EdgeInsets.only(right: 8),
    decoration: item.profilePath.isEmpty
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 1.5),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(item.profilePath),
            ),
          ),
    child: Container(
      padding: padding4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.5, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            item.job,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
