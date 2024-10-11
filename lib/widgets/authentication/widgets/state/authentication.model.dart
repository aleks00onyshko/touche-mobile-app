import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/core/state-change-notifier/state-change-notifier.dart';
import 'package:touche_app/widgets/authentication/widgets/state/state.dart';

class AuthenticationModel extends StateChangeNotifier<AuthenticationState> {
  final FirebaseAuth auth = locator.get<FirebaseAuth>();

  AuthenticationModel(super.initialState);

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

    final UserCredential userCredential = await auth.signInWithCredential(credential);

    patchState({AuthenticationStateKeys.user.name: userCredential.user});

    onSuccess();
  }
}
