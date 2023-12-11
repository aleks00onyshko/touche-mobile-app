import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:tuple/tuple.dart';

class TimeSlotsModel extends ChangeNotifier {
  bool _loading = false;
  List<TimeSlot> _timeSlots = [];
  List<Location> _locations = [];
  List<Teacher> _teachers = [];
  String? _selectedDateId;
  Location? _selectedLocation;
  Exception? _error;

  bool get loading => _loading;

  UnmodifiableListView<TimeSlot> get timeSlots =>
      UnmodifiableListView(_timeSlots);

  UnmodifiableListView<Teacher> get teachers => UnmodifiableListView(_teachers);

  String? get selectedDateId => _selectedDateId;

  UnmodifiableListView<Location> get locations =>
      UnmodifiableListView(_locations);

  Location? get selectedLocation => _selectedLocation;

  Exception? get error => _error;

  TimeSlotsModel() {
    _initializeData();
  }

  void getTimeSlots() async {
    _loading = true;

    notifyListeners();

    _timeSlots = await _getTimeSlots(selectedDateId!, selectedLocation!);
    _loading = false;

    notifyListeners();
  }

  void selectDateId(String dateId) async {
    _selectedDateId = dateId;
    _timeSlots = await _getTimeSlots(selectedDateId!, selectedLocation!);

    notifyListeners();
  }

  void selectLocation(Location location) async {
    _selectedLocation = location;
    _timeSlots = await _getTimeSlots(selectedDateId!, selectedLocation!);

    notifyListeners();
  }

  _initializeData() async {
    final DateTime now = DateTime.now();
    final String dateId =
        '${DateFormat('EEE').format(now)}-${DateFormat('dd').format(now)}-${DateFormat('yyy').format(now)}';

    _loading = true;

    notifyListeners();

    _locations = await _getLocations();
    _teachers = await _getTeachers();
    _selectedLocation = _locations[0];
    _selectedDateId = dateId;
    _timeSlots = await _getTimeSlots(selectedDateId!, selectedLocation!);
    _loading = false;

    notifyListeners();
  }

  Future<List<TimeSlot>> _getTimeSlots(
      String selectedDateId, Location selectedLocation) async {
    final CollectionReference timeSlotsRef = FirebaseFirestore.instance
        .collection('dateIds/$selectedDateId/${selectedLocation.id}-slots');
    final QuerySnapshot querySnapshot = await timeSlotsRef.get();

    return querySnapshot.docs
        .map((doc) => TimeSlot(
            id: doc['id'],
            dateId: doc['dateId'],
            teacherId: doc['teacherId'],
            startTime: Tuple2(doc['startTime'][0], doc['startTime'][1]),
            duration: doc['duration']))
        .toList();
  }

  Future<List<Location>> _getLocations() async {
    final CollectionReference locationsRef =
        FirebaseFirestore.instance.collection('locations');
    final QuerySnapshot querySnapshot = await locationsRef.get();

    return querySnapshot.docs
        .map((doc) => Location(
            id: doc['id'],
            en: doc['displayNames']['en'],
            uk: doc['displayNames']['uk']))
        .toList();
  }

  Future<List<Teacher>> _getTeachers() async {
    final CollectionReference teachersRef =
        FirebaseFirestore.instance.collection('teachers');
    final QuerySnapshot querySnapshot = await teachersRef.get();

    return querySnapshot.docs
        .map((doc) => Teacher(
            id: doc['id'],
            displayName: doc['displayName'],
            email: doc['email'],
            uid: doc['uid']))
        .toList();
  }
}
