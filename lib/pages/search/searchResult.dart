import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wheretowatch/service/master.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  dynamic result;

  @override
  void initState() {
    handleSearchMovies();
    super.initState();
  }

  void handleSearchMovies() async {
    var response = await Master().searchMovie(widget.searchQuery);
    if (mounted) {
      setState(() {
        result = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(),
      ),
      body: SingleChildScrollView(
        child: result == null
            ? CircularProgressIndicator()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result["results"].length,
                itemBuilder: (context, index) {
                  dynamic item = result["results"][index];
                  inspect(item);
                  return ListTile(
                    title: Text(item["title"]),
                  );
                },
              ),
      ),
    );
  }
}
