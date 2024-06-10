import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/models/production_model.dart';

class MovieCastScreen extends StatefulWidget {
  final List<Cast> cast;
  const MovieCastScreen({super.key, required this.cast});

  @override
  State<MovieCastScreen> createState() => _MovieCastScreenState();
}

class _MovieCastScreenState extends State<MovieCastScreen> {
  TextEditingController searchController = TextEditingController();
  List<Cast> filteredCast = [];
  final _debouncer = Debouncer();

  handleSearch(String query) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 750),
      onDebounce: () {
        setState(() {
          if (mounted) {
            filteredCast = widget.cast
                .where(
                  (item) =>
                      item.name.toLowerCase().contains(query.toLowerCase()) ||
                      item.character.toLowerCase().contains(
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
    filteredCast = widget.cast;
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
              hintText: "Search for actor or character",
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
          itemCount: filteredCast.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            Cast cast = filteredCast[index];
            return ListTile(
              leading: cast.profilePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        width: 48,
                        fit: BoxFit.cover,
                        imageUrl: cast.profilePath,
                      ),
                    )
                  : const SizedBox(
                      width: 48,
                    ),
              title: Text(
                cast.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                cast.character,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
    );
  }
}
