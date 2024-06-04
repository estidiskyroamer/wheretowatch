import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:wheretowatch/pages/search/searchResult.dart';
import 'package:wheretowatch/service/master.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        child: Column(
          children: [
            Text("What do you want to watch?"),
            TextField(
              controller: searchController,
              onChanged: (value) {
                _debouncer.debounce(
                    duration: Duration(milliseconds: 500),
                    onDebounce: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchResultScreen(searchQuery: value),
                        ),
                      );
                    });
              },
            )
          ],
        ),
      ),
    ));
  }
}
