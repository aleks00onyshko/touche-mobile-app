import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/state/time-slots-data-provider.dart';

class TimeSlotsModel extends ChangeNotifier {
  final TimeSlotDataProvider dataProvider;

  bool _loading = false;
  List<TimeSlot> _timeSlots = [];
  List<Location> _locations = [];
  List<Teacher> _teachers = [];
  String? _selectedDateId;
  Location? _selectedLocation;
  Exception? _error;
  StreamSubscription<List<TimeSlot>>? _activeSubscription;

  bool get loading => _loading;

  UnmodifiableListView<TimeSlot> get timeSlots => UnmodifiableListView(_timeSlots);

  UnmodifiableListView<Teacher> get teachers => UnmodifiableListView(_teachers);

  String? get selectedDateId => _selectedDateId;

  UnmodifiableListView<Location> get locations => UnmodifiableListView(_locations);

  Location? get selectedLocation => _selectedLocation;

  Exception? get error => _error;

  TimeSlotsModel({required this.dataProvider}) {
    _initialize();
  }

  void selectDateId(String dateId) async {
    _selectedDateId = dateId;

    _switchListenToOtherTimeSlotsCollection(selectedDateId!, selectedLocation!);

    notifyListeners();
  }

  void selectLocation(Location location) async {
    _selectedLocation = location;

    _switchListenToOtherTimeSlotsCollection(selectedDateId!, selectedLocation!);

    notifyListeners();
  }

  _initialize() async {
    _loading = true;

    notifyListeners();

    _locations = await _getLocations();
    _teachers = await _getTeachers();
    _selectedLocation = _locations[0];
    _selectedDateId = _generateDateId();
    _loading = false;

    notifyListeners();

    _switchListenToOtherTimeSlotsCollection(selectedDateId!, selectedLocation!);
  }

  void _switchListenToOtherTimeSlotsCollection(String selectedDateId, Location selectedLocation) {
    _cancelActiveTimeSlotsCollectionSubscription();
    _listenToRespectiveTimeSlotsCollection(selectedDateId, selectedLocation);
  }

  void _cancelActiveTimeSlotsCollectionSubscription() async {
    if (_activeSubscription != null) {
      await _activeSubscription!.cancel();
    }
  }

  void _listenToRespectiveTimeSlotsCollection(String selectedDateId, Location selectedLocation) async {
    _activeSubscription = dataProvider.getTimeSlotsCollectionStream$(selectedDateId, selectedLocation).listen((timeSLots) {
      _timeSlots = timeSLots;

      notifyListeners();
    });
  }

  Future<List<Location>> _getLocations() async {
    return dataProvider.getLocations();
  }

  Future<List<Teacher>> _getTeachers() async {
    return dataProvider.getTeachers();
  }

  String _generateDateId() {
    final DateTime now = DateTime.now();
    return '${DateFormat('EEE').format(now)}-${DateFormat('dd').format(now)}-${DateFormat('yyy').format(now)}';
  }
}
