import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:wheretowatch/common/config.dart';

class MovieCrewScreen extends StatefulWidget {
  final List<dynamic> crew;
  const MovieCrewScreen({super.key, required this.crew});

  @override
  State<MovieCrewScreen> createState() => _MovieCrewScreenState();
}

class _MovieCrewScreenState extends State<MovieCrewScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredCrew = [];
  final _debouncer = Debouncer();

  handleSearch(String query) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 750),
      onDebounce: () {
        setState(() {
          if (mounted) {
            filteredCrew = widget.crew
                .where(
                  (item) =>
                      item["name"]
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      item["job"].toString().toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                )
                .toList();
          }
        });
      },
    );
  }

  @override
  void initState() {
    filteredCrew = widget.crew;
    super.initState();
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
          decoration: InputDecoration(
              hintText: "Search for name or position",
              hintStyle: Theme.of(context).textTheme.labelMedium),
          style: Theme.of(context).textTheme.bodyMedium,
          onChanged: (value) {
            if (value.isNotEmpty) {
              handleSearch(value);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          itemCount: filteredCrew.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> crew = filteredCrew[index];
            return ListTile(
              leading: crew.containsKey("profile_path") &&  crew["profile_path"] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        width: 48,
                        fit: BoxFit.cover,
                        imageUrl:
                            "${Config().imageUrl}${Config().profileSize}${crew["profile_path"]}",
                      ),
                    )
                  : const SizedBox(
                      width: 48,
                    ),
              title: Text(
                crew["name"],
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                crew["job"],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
    );
  }
}
