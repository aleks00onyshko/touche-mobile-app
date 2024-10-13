import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touche_app/core/state-change-notifier/state-change-notifier.dart';
import 'package:touche_app/models/entities/user.dart' as ToucheUser;
import 'package:touche_app/widgets/authentication/widgets/state/authentication_data_provider.dart';
import 'package:touche_app/widgets/authentication/widgets/state/state.dart';

class AuthenticationModel extends StateChangeNotifier<AuthenticationState> {
  final FirebaseAuth auth;
  final AuthenticationDataProvider dataProvider;

  AuthenticationModel(super.initialState, {required this.auth, required this.dataProvider});

  User? getCurrentLoggedInUser() {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle({required VoidCallback onSuccess}) async {
    patchState({AuthenticationStateKeys.loading.name: true});

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential userCredential = await auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? true) {
        dataProvider.createUser(_convertFirestoreUserToToucheUser(userCredential.user!, userCredential.additionalUserInfo!));
      }

      patchState({AuthenticationStateKeys.user.name: userCredential.user});

      onSuccess();
    } catch (err) {
      // ...snackbar and error logic here
    }
  }

  ToucheUser.User _convertFirestoreUserToToucheUser(User user, AdditionalUserInfo additionalInfo) {
    return ToucheUser.User(
        id: user.uid,
        displayName: user.displayName ?? 'Anonym',
        backgroundImageUrl: user.photoURL ?? '',
        email: user.email ?? 'anonymous@email.com',
        uid: user.uid);
  }
}
