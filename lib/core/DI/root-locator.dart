import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots-data-provider.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';

final locator = GetIt.instance;

void setupLocator(FirebaseFirestore firebaseApp) {
  locator.registerSingleton<FirebaseFirestore>(firebaseApp);
  locator.registerSingleton(TimeSlotsDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));
  locator.registerSingleton(TimeSlotModalDataProvider(firebaseApp: locator.get<FirebaseFirestore>()));
  locator.registerSingleton<TimeSlotsModel>(TimeSlotsModel(dataProvider: locator.get<TimeSlotsDataProvider>()));
  locator.registerFactoryParam<TimeSlotModalModel, TimeSlotModalDataProvider, TimeSlot>(
      (dataProvider, timeSlot) => TimeSlotModalModel(timeSlotModalInitialState, dataProvider: dataProvider, timeSlot: timeSlot));
}
