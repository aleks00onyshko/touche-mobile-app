import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touche_app/models/entities/user.dart';

class AuthenticationDataProvider {
  final FirebaseFirestore firebaseApp;

  AuthenticationDataProvider({required this.firebaseApp});

  Future<void> createUser(User user) async {
    await firebaseApp.collection('users').doc(user.id).set(user.toJson());
  }
}
