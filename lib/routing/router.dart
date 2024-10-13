import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/widgets/authentication/widgets/authentication.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots-data-provider.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slots.dart';

final touche_router = GoRouter(
  initialLocation: '/authentication',
  routes: [
    GoRoute(
      path: '/timeSlots',
      builder: (context, state) {
        if (!locator.isRegistered<TimeSlotsDataProvider>()) {
          locator.registerSingleton(TimeSlotsDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));
        }

        if (!locator.isRegistered<TimeSlotsModel>()) {
          locator.registerSingleton<TimeSlotsModel>(TimeSlotsModel(timeSlotsInitialState,
              dataProvider: locator.get<TimeSlotsDataProvider>(), authenticationModel: locator.get<AuthenticationModel>()));
        }

        return TimeSlots(model: locator.get<TimeSlotsModel>());
      },
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
