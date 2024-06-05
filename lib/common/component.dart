import 'package:flutter/material.dart';

Container iconWithText(BuildContext context, IconData iconData, String text) {
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
          child: 
            Text(
              text,
              maxLines: 2,
              softWrap: true,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.white),
            ),
          
        )
      ],
    ),
  );
}
