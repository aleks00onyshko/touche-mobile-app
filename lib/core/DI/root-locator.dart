import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication_data_provider.dart';
import 'package:touche_app/widgets/authentication/widgets/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';

final locator = GetIt.instance;

void setupLocator(FirebaseFirestore firebaseApp) {
  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  locator.registerSingleton<FirebaseFirestore>(firebaseApp);
  locator
      .registerSingleton<AuthenticationDataProvider>(AuthenticationDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));
  locator.registerSingleton<AuthenticationModel>(AuthenticationModel(authenticationInitialState,
      auth: locator.get<FirebaseAuth>(), dataProvider: locator.get<AuthenticationDataProvider>()));
  locator.registerSingleton(TimeSlotModalDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));

  locator.registerFactoryParam<TimeSlotModalModel, TimeSlotModalDataProvider, TimeSlot>((dataProvider, timeSlot) =>
      TimeSlotModalModel(timeSlotModalInitialState,
          dataProvider: dataProvider, timeSlot: timeSlot, authenticationModel: locator.get<AuthenticationModel>()));
}
