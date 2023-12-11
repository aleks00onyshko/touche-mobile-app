import 'package:touche_app/models/entities/entity.dart';

class Location extends Entity<String> {
  Location({required String id, required String en, required String uk})
      : super(id) {
    displayNames = {'en': en, 'uk': uk};
  }

  late Map<String, String> displayNames;
}
