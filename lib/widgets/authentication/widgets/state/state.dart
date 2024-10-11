import 'package:firebase_auth/firebase_auth.dart';
import 'package:touche_app/core/state-change-notifier/state.dart';

enum AuthenticationStateKeys { loading, user }

interface class AuthenticationState implements ChangeNotifierState {
  late bool loading = false;
  User? user;

  @override
  Map<String, dynamic> toMap() {
    return {AuthenticationStateKeys.loading.name: loading, AuthenticationStateKeys.user.name: user};
  }
}

AuthenticationState authenticationInitialState = AuthenticationState();
