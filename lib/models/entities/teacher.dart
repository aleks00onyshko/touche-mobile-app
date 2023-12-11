import 'package:touche_app/models/entities/entity.dart';

class Teacher extends Entity<String> {
  Teacher(
      {required String id,
      required this.displayName,
      required this.email,
      required this.uid})
      : super(id);

  late String displayName;
  late String email;
  late String uid;
}
