import 'package:touche_app/models/entities/entity.dart';

class Location implements Entity<String> {
  Location({required this.id, required this.displayNames});

  @override
  late String id;
  late Map<String, String> displayNames;

  @override
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(id: json['id'], displayNames: {
      'en': json['displayNames']['en'],
      'uk': json['displayNames']['uk'],
    });
  }

  @override
  toJson() {
    return {'id': id, 'displayNames': displayNames};
  }
}
