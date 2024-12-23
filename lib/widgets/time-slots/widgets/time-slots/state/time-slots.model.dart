import 'dart:async';

import 'package:intl/intl.dart';
import 'package:touche_app/core/state-change-notifier/state-change-notifier.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots-data-provider.dart';

class TimeSlotsModel extends StateChangeNotifier<TimeSlotsState> {
  final TimeSlotsDataProvider dataProvider;
  final AuthenticationModel authenticationModel;

  StreamSubscription<List<TimeSlot>>? _activeSubscription;

  TimeSlotsModel(super.initialState, {required this.dataProvider, required this.authenticationModel}) {
    _initialize();
  }

  @override
  void dispose() {
    _cancelActiveTimeSlotsCollectionSubscription();
    super.dispose();
  }

  void selectDateId(String dateId) async {
    patchState({TimeSlotsStateKeys.selectedDateId.name: dateId});

    _switchListenToOtherTimeSlotsCollection(dateId);
  }

  void selectLocation(Location location) async {
    patchState({TimeSlotsStateKeys.selectedLocation.name: location});
  }

  void _initialize() async {
    patchState({TimeSlotsStateKeys.loading.name: true});

    dataProvider.getLocations().then((locations) async {
      patchState({
        TimeSlotsStateKeys.locations.name: locations,
        TimeSlotsStateKeys.teachers.name: await dataProvider.getTeachers(),
        TimeSlotsStateKeys.selectedLocation.name: locations[0],
        TimeSlotsStateKeys.selectedDateId.name: _generateDateId(),
        TimeSlotsStateKeys.loading.name: false
      });

      _switchListenToOtherTimeSlotsCollection(state['selectedDateId']);
    });
  }

  void _switchListenToOtherTimeSlotsCollection(String selectedDateId) {
    _cancelActiveTimeSlotsCollectionSubscription();
    _listenToRespectiveTimeSlotsCollection(selectedDateId);
  }

  void _cancelActiveTimeSlotsCollectionSubscription() async {
    if (_activeSubscription != null) {
      await _activeSubscription!.cancel();
    }
  }

  void _listenToRespectiveTimeSlotsCollection(String selectedDateId) async {
    _activeSubscription = dataProvider
        .getTimeSlotsCollectionStream$(selectedDateId, authenticationModel.getCurrentLoggedInUser()!.uid)
        .listen((timeSLots) {
      patchState({TimeSlotsStateKeys.timeSlots.name: timeSLots});
    });
  }

  String _generateDateId() {
    final DateTime now = DateTime.now();

    return '${DateFormat('dd').format(now)}-${DateFormat('MM').format(now)}-${DateFormat('yyy').format(now)}';
  }
}
