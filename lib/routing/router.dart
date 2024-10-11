import 'package:go_router/go_router.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/widgets/authentication/widgets/authentication.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slots.dart';

final touche_router = GoRouter(
  initialLocation: '/authentication',
  routes: [
    GoRoute(
      path: '/timeSlots',
      builder: (context, state) => const TimeSlots(),
    ),
    GoRoute(
      path: '/authentication',
      builder: (context, state) => Authentication(),
    ),
  ],
  redirect: (context, state) {
    final authModel = locator.get<AuthenticationModel>();
    final loggedIn = authModel.getCurrentLoggedInUser() != null;

    if (!loggedIn) {
      return '/authentication';
    }

    if (loggedIn && state.fullPath == '/authentication') {
      return '/timeSlots';
    }

    return null;
  },
);
