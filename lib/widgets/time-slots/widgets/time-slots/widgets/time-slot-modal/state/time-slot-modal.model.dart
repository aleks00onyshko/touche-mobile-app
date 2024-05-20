import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:signals/signals.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';
import 'package:tuple/tuple.dart';

class TimeSlotModalModel extends ChangeNotifier {
  final TimeSlotModalDataProvider dataProvider;
  final TimeSlot timeSlot;

  late bool _loading = false;
  late bool _booked;
  late Tuple2<int, int> _startTime;
  late int _duration;
  late String? _selectedTeacherId;
  late int _selectedTeacherIndex;
  late List<Teacher> _fetchedTeachers = [];
  late StreamSubscription<TimeSlot>? _activeSubscription;

  final Signal<List<String>> _teachersIdsSignal = signal([]);
  final Signal<String> _locationIdSignal = signal('');

  bool get loading => _loading;
  UnmodifiableListView<Teacher> get fetchedTeachers => UnmodifiableListView(_fetchedTeachers);
  String? get selectedTeacherId => _selectedTeacherId;
  int get selectedTeacherIndex => _selectedTeacherIndex;

  void selectNextTeacher() {
    _selectedTeacherId = _fetchedTeachers[_selectedTeacherIndex + 1].id;
    _selectedTeacherIndex = _selectedTeacherIndex + 1;

    notifyListeners();
  }

  void selectPreviousTeacher() {
    _selectedTeacherId = _fetchedTeachers[_selectedTeacherIndex - 1].id;
    _selectedTeacherIndex = _selectedTeacherIndex - 1;

    notifyListeners();
  }

  void selectTeacher(String teacherId) {
    _selectedTeacherId = teacherId;
    _selectedTeacherIndex = _getSelectedTeacherIndex(_selectedTeacherId!);

    notifyListeners();
  }

  TimeSlotModalModel({required this.dataProvider, required this.timeSlot}) {
    _setStateBasedOnInitialTimeSlot(timeSlot);
    _initialize(timeSlot);
  }

  void _setStateBasedOnInitialTimeSlot(TimeSlot timeSlot) {
    _booked = timeSlot.booked;
    _startTime = timeSlot.startTime;
    _duration = timeSlot.duration;
    _selectedTeacherId = timeSlot.selectedTeacherId ?? timeSlot.teachersIds.first;

    notifyListeners();
  }

  void _initialize(TimeSlot timeSlot) async {
    _loading = true;

    notifyListeners();

    _teachersIdsSignal.value = timeSlot.teachersIds;
    _fetchedTeachers = await dataProvider.getTeachersByIds(timeSlot.teachersIds);
    _selectedTeacherIndex = _getSelectedTeacherIndex(_selectedTeacherId!);
    _loading = false;

    notifyListeners();

    effect(() => {_fetchAndReplaceTeachers(_teachersIdsSignal.value)});

    _listenToTimeSlotDocChanges(timeSlot);
  }

  void _listenToTimeSlotDocChanges(TimeSlot timeSlot) {
    _activeSubscription =
        dataProvider.getTimeSlotDocumentStream$(timeSlot.id, timeSlot.dateId, timeSlot.locationId).listen((incomingTimeSlot) {
      _teachersIdsSignal.value = incomingTimeSlot.teachersIds;
      _locationIdSignal.value = incomingTimeSlot.locationId;
    });
  }

  void _fetchAndReplaceTeachers(List<String> teachersIds) async {
    _fetchedTeachers = await dataProvider.getTeachersByIds(teachersIds);
    notifyListeners();
  }

  int _getSelectedTeacherIndex(String selectedTeacherId) {
    return _fetchedTeachers.indexWhere((teacher) => teacher.id == selectedTeacherId);
  }

  void _cancelActiveTimeSlotCollectionSubscription() async {
    if (_activeSubscription != null) {
      await _activeSubscription!.cancel();
    }
  }
}
