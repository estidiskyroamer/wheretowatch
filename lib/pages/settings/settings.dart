import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/service/configuration.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<dynamic> countries = [];
  String? selectedCountry;

  @override
  void initState() {
    handleCountries();
    super.initState();
  }

  handleCountries() async {
    if (!Prefs().preferences.containsKey("region")) {
      Prefs().preferences.setString("region", "US");
      Prefs().preferences.setString("region_name", "United States of America");
    }
    dynamic countryCode = Prefs().preferences.getString("region");
    inspect(countryCode);
    dynamic result = await Configuration().getCountries();
    if (mounted) {
      setState(() {
        countries = result;
        selectedCountry = countryCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.xmark))
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            children: [
              Text(
                "Region",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              DropdownButtonHideUnderline(
                  child: DropdownButton2(
                isExpanded: true,
                buttonStyleData:
                    const ButtonStyleData(padding: EdgeInsets.all(16)),
                dropdownStyleData: DropdownStyleData(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width / 1.2,
                    maxHeight: MediaQuery.of(context).size.height / 1.5,
                    decoration:
                        BoxDecoration(color: Theme.of(context).indicatorColor)),
                hint: Text(
                  'Select Item',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                value: countries.isNotEmpty ? selectedCountry : null,
                items: countries.map((country) {
                  if (selectedCountry == country["iso_3166_1"]) {
                    Prefs()
                        .preferences
                        .setString("region_name", country["english_name"]);
                  }
                  return DropdownMenuItem<String>(
                    value: country["iso_3166_1"],
                    child: Text(
                      country["english_name"],
                      style: selectedCountry != country["iso_3166_1"]
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    inspect(value);
                    selectedCountry = value;
                    Prefs().preferences.setString("region", selectedCountry!);
                  });
                },
              ))
            ],
          ),
        ));
  }
}
