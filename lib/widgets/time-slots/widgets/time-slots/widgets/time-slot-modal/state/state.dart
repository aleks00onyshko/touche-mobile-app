import 'package:touche_app/core/state-change-notifier/state.dart';
import 'package:touche_app/models/entities/teacher.dart';

enum TimeSlotModalStateKeys { loading, teachers, booked, duration, selectedTeacher, attendeeId, bookButtonDisabled }

interface class TimeSlotModalState implements ChangeNotifierState {
  late bool loading = false;
  late List<Teacher> teachers = [];
  late bool booked = false;
  late int duration = 0;
  late bool bookButtonDisabled = false;
  String? attendeeId;
  Teacher? selectedTeacher;

  @override
  Map<String, dynamic> toMap() {
    return {
      TimeSlotModalStateKeys.loading.name: loading,
      TimeSlotModalStateKeys.teachers.name: teachers,
      TimeSlotModalStateKeys.booked.name: booked,
      TimeSlotModalStateKeys.duration.name: duration,
      TimeSlotModalStateKeys.selectedTeacher.name: selectedTeacher,
      TimeSlotModalStateKeys.attendeeId.name: attendeeId,
      TimeSlotModalStateKeys.bookButtonDisabled.name: bookButtonDisabled
    };
  }
}

TimeSlotModalState timeSlotModalInitialState = TimeSlotModalState();
