import 'package:touche_app/models/entities/entity.dart';

class Teacher implements Entity<String> {
  Teacher({required this.id, required this.displayName, required this.imageUrl, required this.email, required this.uid});

  @override
  late String id;
  late String displayName;
  late String imageUrl;
  late String email;
  late String uid;

  @override
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
        id: json['id'],
        displayName: json['displayName'],
        email: json['email'],
        uid: json['uid'],
        imageUrl: json['imageUrl'] ?? '');
  }

  @override
  toJson() {
    return {'id': id, 'displayName': displayName, 'email': email, 'uid': uid};
  }
}
