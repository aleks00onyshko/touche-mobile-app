import 'package:touche_app/models/entities/entity.dart';

class User implements Entity<String> {
  User({required this.id, required this.displayName, required this.backgroundImageUrl, required this.email, required this.uid});

  @override
  late String id;
  late String displayName;
  late String backgroundImageUrl;
  late String email;
  late String uid;

  @override
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      displayName: json['displayName'],
      email: json['email'],
      uid: json['uid'],
      backgroundImageUrl: json['imageUrl'] ?? '',
    );
  }

  @override
  toJson() {
    return {'id': id, 'displayName': displayName, 'email': email, 'uid': uid, 'backgroundImageUrl': backgroundImageUrl};
  }
}
