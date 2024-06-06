import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wheretowatch/common/config.dart';

Widget streamingServiceItem(BuildContext context, Map<String, dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
            height: 48,
            imageUrl:
                "${Config().imageUrl}${Config().logoSize}${item["logo_path"]}"),
      ),
      Container(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          item["provider_name"],
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
            maxLines: 2,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
      ],
    ),
  );
}

Widget castItem(BuildContext context, Map<String, dynamic> item) {
  return Container(
    height: MediaQuery.of(context).size.height / 5,
    width: MediaQuery.of(context).size.width / 4,
    margin: const EdgeInsets.only(right: 8),
    padding: padding4,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: DecorationImage(
        fit: BoxFit.cover,
        image: CachedNetworkImageProvider(
            "${Config().imageUrl}${Config().profileSize}${item["profile_path"]}"),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item["name"],
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          item["character"],
          maxLines: 3,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

Widget crewItem(BuildContext context, Map<String, dynamic> item) {
  return Container(
    height: MediaQuery.of(context).size.height / 5,
    width: MediaQuery.of(context).size.width / 4,
    margin: const EdgeInsets.only(right: 8),
    padding: padding4,
    decoration: item["profile_path"] == null || item["profile_path"] == "null"
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
              image: CachedNetworkImageProvider(
                  "${Config().imageUrl}${Config().profileSize}${item["profile_path"]}"),
            ),
          ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item["name"],
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          item["job"],
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

EdgeInsetsGeometry padding16 = const EdgeInsets.all(16);

EdgeInsetsGeometry padding8 = const EdgeInsets.all(8);

EdgeInsetsGeometry padding4 = const EdgeInsets.all(4);
