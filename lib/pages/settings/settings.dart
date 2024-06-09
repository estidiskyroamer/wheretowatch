import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wheretowatch/common/config.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/models/country_model.dart';
import 'package:wheretowatch/service/configuration.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Country> countries = [];
  String? selectedCountry;

  @override
  void initState() {
    handleCountries();
    super.initState();
  }

  handleCountries() async {
    dynamic countryCode = Prefs().preferences.getString("region");
    inspect(countryCode);
    dynamic result = await Configuration().getCountries();
    if (mounted) {
      setState(() {
        countries = List<Country>.from(
            result.map((x) => Country.fromJson(x)));
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
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        body: Center(
          child: Column(
            children: [
              Text(
                "Region",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: padding16,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                  isExpanded: true,
                  buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.inverseSurface)),
                  dropdownStyleData: DropdownStyleData(
                    padding: padding8,
                    useRootNavigator: true,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  hint: Text(
                    'Select Item',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  value: countries.isNotEmpty ? selectedCountry : null,
                  items: countries.map((country) {
                    if (selectedCountry == country.countryCode) {
                      Prefs()
                          .preferences
                          .setString("region_name", country.countryName);
                    }
                    return DropdownMenuItem<String>(
                      value: country.countryCode,
                      child: Text(
                        country.countryName,
                        style: selectedCountry != country.countryCode
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context)
                                .textTheme
                                .bodyMedium!
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
                )),
              )
            ],
          ),
        ));
  }
}
