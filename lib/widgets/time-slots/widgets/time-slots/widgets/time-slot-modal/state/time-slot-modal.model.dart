import 'dart:async';

import 'package:signals/signals.dart';
import 'package:touche_app/core/state-change-notifier/state-change-notifier.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';

class TimeSlotModalModel extends StateChangeNotifier {
  final TimeSlotModalDataProvider dataProvider;
  final TimeSlot timeSlot;

  late StreamSubscription<TimeSlot>? _activeSubscription;

  final Signal<List<String>> _teachersIdsSignal = signal([]);
  final Signal<String> _selectedTeacherIdSignal = signal('');
  final Signal<String> _atendeeIdSignal = signal('');

  void changeSelectedTeacher(Teacher teacher) {
    patchState({TimeSlotModalStateKeys.selectedTeacher.name: teacher});
  }

  void toggleBookedState() {
    patchState({TimeSlotModalStateKeys.booked.name: !state['booked']});
  }

  TimeSlotModalModel(TimeSlotModalState super.initialState, {required this.dataProvider, required this.timeSlot}) {
    _setStateBasedOnInitialTimeSlot(timeSlot);
    _initialize(timeSlot);
  }

  void _setStateBasedOnInitialTimeSlot(TimeSlot timeSlot) {
    patchState({
      TimeSlotModalStateKeys.booked.name: timeSlot.booked,
      TimeSlotModalStateKeys.duration.name: timeSlot.duration,
    });
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
      if (_selectedTeacherIdSignal.value.isNotEmpty) {
        final Teacher selectedTeacher = _getSelectedTeacher(state['teachers'], _selectedTeacherIdSignal.value);

        patchState({
          TimeSlotModalStateKeys.selectedTeacher.name: selectedTeacher,
          TimeSlotModalStateKeys.teachers.name: [selectedTeacher]
        });
      }
    });

    effect(() {
      if (_atendeeIdSignal.value.isNotEmpty && _atendeeIdSignal.previousValue != _atendeeIdSignal.value) {
        patchState({TimeSlotModalStateKeys.attendeeId.name: _atendeeIdSignal.value, TimeSlotModalStateKeys.booked.name: true});
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
    _selectedTeacherIdSignal.value = timeSlot.selectedTeacherId ?? '';
    _atendeeIdSignal.value = timeSlot.attendeeId ?? '';
  }

  Future<void> _loadAndSetInitialData(TimeSlot timeSlot) async {
    patchState({TimeSlotModalStateKeys.loading.name: true});

    return _loadTeachers(timeSlot.teachersIds).then((teachers) {
      patchState({
        TimeSlotModalStateKeys.teachers.name: teachers,
        TimeSlotModalStateKeys.loading.name: false,
      });

      patchState({TimeSlotModalStateKeys.selectedTeacher.name: _getSelectedTeacher(teachers, timeSlot.selectedTeacherId)});
    });
  }

  Teacher _getSelectedTeacher(List<Teacher> teachers, String? selectedTeacherId) {
    return selectedTeacherId != null ? teachers.firstWhere((teacher) => teacher.id == selectedTeacherId) : teachers.first;
  }

  void _loadAndReplaceTeachers(List<String> teachersIds) async {
    patchState({TimeSlotModalStateKeys.teachers.name: await _loadTeachers(teachersIds)});
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
