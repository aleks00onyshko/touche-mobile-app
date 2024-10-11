import 'dart:async';

import 'package:signals/signals.dart';
import 'package:touche_app/core/state-change-notifier/state-change-notifier.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';

class TimeSlotModalModel extends StateChangeNotifier {
  final TimeSlotModalDataProvider dataProvider;
  final TimeSlot timeSlot;
  final AuthenticationModel authenticationModel;

  late StreamSubscription<TimeSlot>? _activeSubscription;

  final Signal<List<String>> _teachersIdsSignal = signal([]);
  final Signal<String> _atendeeIdSignal = signal('');

  void changeSelectedTeacher(Teacher teacher) {
    patchState({TimeSlotModalStateKeys.selectedTeacher.name: teacher});
  }

  void toggleBookedState() async {
    patchState({
      TimeSlotModalStateKeys.booked.name: !state['booked'],
      TimeSlotModalStateKeys.attendeeId.name: state['booked'] ? '' : authenticationModel.getCurrentLoggedInUser()!.uid,
    });

    await dataProvider.setTimeSlotBookedState(
        booked: state['booked'],
        attendeeId: state['attendeeId'],
        timeSlotId: timeSlot.id,
        dateId: timeSlot.dateId,
        locationId: timeSlot.locationId);
  }

  TimeSlotModalModel(TimeSlotModalState super.initialState,
      {required this.dataProvider, required this.timeSlot, required this.authenticationModel}) {
    _initialize(timeSlot);
  }

  void _initialize(TimeSlot timeSlot) async {
    await _loadAndSetInitialData(timeSlot);

    _initializeListeners(timeSlot);
  }

  void _initializeListeners(TimeSlot timeSlot) {
    _listenToTimeSlotDocChanges(timeSlot);

    effect(() {
      if (_teachersIdsSignal.value.isNotEmpty) {
        _loadAndReplaceTeachers(_teachersIdsSignal.value);
      }
    });

    effect(() {
      if (_atendeeIdSignal.value.isNotEmpty) {
        patchState({
          TimeSlotModalStateKeys.attendeeId.name: _atendeeIdSignal.value,
          TimeSlotModalStateKeys.booked.name: true,
          TimeSlotModalStateKeys.bookButtonDisabled.name:
              _atendeeIdSignal.value != authenticationModel.getCurrentLoggedInUser()!.uid
        });
      } else {
        patchState({
          TimeSlotModalStateKeys.attendeeId.name: '',
          TimeSlotModalStateKeys.booked.name: false,
          TimeSlotModalStateKeys.bookButtonDisabled.name: false
        });
      }
    });
  }

  void _listenToTimeSlotDocChanges(TimeSlot timeSlot) {
    _activeSubscription = dataProvider
        .getTimeSlotDocumentStream$(timeSlot.id, timeSlot.dateId, timeSlot.locationId)
        .skip(1)
        .listen((incomingTimeSlot) => _updateSignals(incomingTimeSlot));
  }

  void _updateSignals(TimeSlot timeSlot) {
    _teachersIdsSignal.value = timeSlot.teachersIds;
    _atendeeIdSignal.value = timeSlot.attendeeId ?? '';
  }

  Future<void> _loadAndSetInitialData(TimeSlot timeSlot) async {
    patchState({TimeSlotModalStateKeys.loading.name: true});

    return _loadTeachers(timeSlot.teachersIds).then((teachers) {
      patchState({
        TimeSlotModalStateKeys.teachers.name: teachers,
        TimeSlotModalStateKeys.loading.name: false,
        TimeSlotModalStateKeys.selectedTeacher.name: teachers.first,
        TimeSlotModalStateKeys.booked.name: timeSlot.booked,
        TimeSlotModalStateKeys.duration.name: timeSlot.duration
      });
    });
  }

  Future<void> _loadAndReplaceTeachers(List<String> teachersIds) async {
    _loadTeachers(teachersIds).then((teachers) {
      patchState({
        TimeSlotModalStateKeys.teachers.name: teachers,
        TimeSlotModalStateKeys.selectedTeacher.name: teachers.firstWhere((teacher) {
          return teacher.id == state['selectedTeacher'];
        }, orElse: () => teachers.first)
      });
    });
  }

  Future<List<Teacher>> _loadTeachers(List<String> teachersIds) {
    return dataProvider.getTeachersByIds(teachersIds);
  }

  @override
  void dispose() {
    super.dispose();
    _cancelActiveTimeSlotCollectionSubscription();
  }

  void _cancelActiveTimeSlotCollectionSubscription() async {
    if (_activeSubscription != null) {
      await _activeSubscription!.cancel();
    }
  }
}
