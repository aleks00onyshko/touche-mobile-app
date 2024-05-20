import 'package:flutter/material.dart';
import 'package:touche_app/models/entities/location.dart';

class LocationSelect extends StatelessWidget {
  final List<Location> locations;
  final Function(Location) onLocationSelected;

  const LocationSelect({super.key, required this.locations, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    final TextEditingController locationController = TextEditingController();

    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: DropdownMenu<Location>(
          inputDecorationTheme: const InputDecorationTheme(outlineBorder: BorderSide.none, border: InputBorder.none),
          initialSelection: locations[0],
          onSelected: (Location? location) {
            onLocationSelected(location as Location);
          },
          dropdownMenuEntries: locations.map<DropdownMenuEntry<Location>>((Location location) {
            return DropdownMenuEntry<Location>(value: location, label: location.displayNames['uk'] ?? 'Location');
          }).toList(),
        ));
  }
}
