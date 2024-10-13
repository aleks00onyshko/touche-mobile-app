import 'package:touche_app/models/entities/entity.dart';

import 'user.dart';

class Teacher extends User implements Entity<String> {
  Teacher(
      {required super.id,
      required super.displayName,
      required super.backgroundImageUrl,
      required super.email,
      required super.uid,
      required this.number,
      required this.description});

  late String description;
  late String number;

  @override
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
        id: json['id'],
        displayName: json['displayName'],
        email: json['email'],
        number: json['number'],
        uid: json['uid'],
        backgroundImageUrl: json['imageUrl'] ?? '',
        description: json['description'] ?? '');
  }

  @override
  toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'number': number,
      'backgroundImageUrl': backgroundImageUrl,
      'description': description
    };
  }
}
