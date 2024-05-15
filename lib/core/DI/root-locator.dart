import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:touche_app/state/time-slots-data-provider.dart';
import 'package:touche_app/state/time-slots.model.dart';

final locator = GetIt.instance;

void setupLocator(FirebaseFirestore firebaseApp) {
  locator.registerSingleton<FirebaseFirestore>(firebaseApp);
  locator.registerSingleton(TimeSlotDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));
  locator.registerSingleton<TimeSlotsModel>(TimeSlotsModel(dataProvider: locator.get<TimeSlotDataProvider>()));
}
