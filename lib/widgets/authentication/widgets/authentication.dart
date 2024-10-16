import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/routing/router.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/shared/widgets/loading.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthenticationModel>.value(
      value: locator.get<AuthenticationModel>(),
      child: Consumer<AuthenticationModel>(
        builder: (BuildContext context, model, child) {
          if (model.state['loading']) {
            return const Center(child: Loading());
          }

          return Scaffold(
              appBar: AppBar(
                title: const Text('Welcome to Touche'),
              ),
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await model.signInWithGoogle(onSuccess: () {
                        touche_router.go('/timeSlots');
                      });
                    },
                    child: const Text('Sign in with Google'),
                  ),
                ],
              )));
        },
      ),
    );
  }
}
