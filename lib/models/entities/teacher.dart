import 'package:touche_app/models/entities/entity.dart';

class Teacher implements Entity<String> {
  Teacher(
      {required this.id,
      required this.displayName,
      required this.backgroundImageUrl,
      required this.email,
      required this.uid,
      required this.description});

  @override
  late String id;
  late String displayName;
  late String description;
  late String backgroundImageUrl;
  late String email;
  late String uid;

  @override
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
        id: json['id'],
        displayName: json['displayName'],
        email: json['email'],
        uid: json['uid'],
        backgroundImageUrl: json['imageUrl'] ?? '',
        description: json['description'] ?? '');
  }

  @override
  toJson() {
    return {'id': id, 'displayName': displayName, 'email': email, 'uid': uid};
  }
}
