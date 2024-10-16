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

  final Signal<List<String>> _teachersIdsSignal = signal([], autoDispose: true);
  late EffectCallback _teachersIdsEffectDisposeFn;
  final Signal<String?> _atendeeIdSignal = signal(null, autoDispose: true);
  late EffectCallback _atendeeIdEffectDisposeFn;

  void changeSelectedTeacher(Teacher teacher) {
    patchState({TimeSlotModalStateKeys.selectedTeacher.name: teacher});
  }

  Future<void> bookTimeSlot() async {
    try {
      patchState({
        TimeSlotModalStateKeys.booked.name: true,
        TimeSlotModalStateKeys.attendeeId.name: authenticationModel.getCurrentLoggedInUser()!.uid,
      });
      await dataProvider.bookTimeSlot(timeSlot, authenticationModel.getCurrentLoggedInUser()!.uid, state['selectedTeacher'].id);
    } catch (e) {
      patchState({
        TimeSlotModalStateKeys.booked.name: false,
        TimeSlotModalStateKeys.snackbarText.name: 'Error booking the time slot. Please try again.'
      });
    }
  }

  Future<void> unBookTimeSlot() async {
    try {
      patchState({
        TimeSlotModalStateKeys.booked.name: false,
        TimeSlotModalStateKeys.attendeeId.name: '',
      });

      await dataProvider.unBookTimeSlot(timeSlot);
    } catch (e) {
      patchState({
        TimeSlotModalStateKeys.booked.name: true,
        TimeSlotModalStateKeys.snackbarText.name: 'Error unbooking the time slot. Please try again.'
      });
    }
  }

  void closeSnackbar() {
    patchState({TimeSlotModalStateKeys.snackbarText.name: ''});
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

    _teachersIdsEffectDisposeFn = effect(() {
      if (_teachersIdsSignal.value.isNotEmpty && _teachersIdsSignal.previousValue?.length != _teachersIdsSignal.value.length) {
        _loadAndReplaceTeachers(_teachersIdsSignal.value);
      }
    });

    _atendeeIdEffectDisposeFn = effect(() {
      if (_atendeeIdSignal.value != null) {
        patchState({
          TimeSlotModalStateKeys.attendeeId.name: _atendeeIdSignal.value,
          TimeSlotModalStateKeys.booked.name: (_atendeeIdSignal.value as String).isNotEmpty,
          TimeSlotModalStateKeys.bookButtonDisabled.name:
              _atendeeIdSignal.value!.isNotEmpty && _atendeeIdSignal.value != authenticationModel.getCurrentLoggedInUser()!.uid
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

    try {
      final List<Teacher> teachers = await _loadTeachers(timeSlot.teachersIds);

      patchState({
        TimeSlotModalStateKeys.teachers.name: teachers,
        TimeSlotModalStateKeys.loading.name: false,
        TimeSlotModalStateKeys.selectedTeacher.name:
            teachers.firstWhere((teacher) => teacher.id == timeSlot.selectedTeacherId, orElse: () => teachers.first),
        TimeSlotModalStateKeys.bookButtonDisabled.name: timeSlot.attendeeId != null &&
            timeSlot.attendeeId!.isNotEmpty &&
            timeSlot.attendeeId != authenticationModel.getCurrentLoggedInUser()!.uid,
        TimeSlotModalStateKeys.attendeeId.name: timeSlot.attendeeId ?? '',
        TimeSlotModalStateKeys.booked.name: timeSlot.booked,
        TimeSlotModalStateKeys.duration.name: timeSlot.duration
      });
    } catch (e) {
      patchState({
        TimeSlotModalStateKeys.booked.name: true,
        TimeSlotModalStateKeys.snackbarText.name: 'Error during initialization, try later please!'
      });
    }
  }

  Future<void> _loadAndReplaceTeachers(List<String> teachersIds) async {
    _loadTeachers(teachersIds).then((teachers) {
      patchState({
        TimeSlotModalStateKeys.teachers.name: teachers,
        TimeSlotModalStateKeys.selectedTeacher.name: teachers.firstWhere((teacher) {
          return teacher.id == state['selectedTeacher'].id;
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
    _teachersIdsEffectDisposeFn();
    _atendeeIdEffectDisposeFn();
  }

  void _cancelActiveTimeSlotCollectionSubscription() async {
    if (_activeSubscription != null) {
      await _activeSubscription!.cancel();
    }
  }
}
