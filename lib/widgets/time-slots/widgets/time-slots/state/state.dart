import 'package:touche_app/core/state-change-notifier/state.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';

enum TimeSlotsStateKeys { loading, timeSlots, locations, teachers, selectedDateId, selectedLocation, error }

interface class TimeSlotsState implements ChangeNotifierState {
  late bool loading = false;
  late List<TimeSlot> timeSlots = [];
  late List<Location> locations = [];
  late List<Teacher> teachers = [];
  String? selectedDateId;
  Location? selectedLocation;
  Exception? error;

  @override
  Map<String, dynamic> toMap() {
    return {
      TimeSlotsStateKeys.loading.name: loading,
      TimeSlotsStateKeys.timeSlots.name: timeSlots,
      TimeSlotsStateKeys.locations.name: locations,
      TimeSlotsStateKeys.teachers.name: teachers,
      TimeSlotsStateKeys.selectedDateId.name: selectedDateId,
      TimeSlotsStateKeys.selectedLocation.name: selectedLocation,
      TimeSlotsStateKeys.error.name: error,
    };
  }
}

TimeSlotsState timeSlotsInitialState = TimeSlotsState();
