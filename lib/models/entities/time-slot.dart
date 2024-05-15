import 'package:touche_app/models/entities/entity.dart';
import 'package:tuple/tuple.dart';

class TimeSlot implements Entity<String> {
  TimeSlot({
    required this.id,
    required this.duration,
    required this.teachersIds,
    required this.dateId,
    required this.startTime,
    this.selectedTeacherId,
  });

  @override
  late String id;
  late Tuple2<int, int> startTime;
  late int duration;
  late List<String> teachersIds;
  late String dateId;
  late String? selectedTeacherId;

  @override
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
        id: json['id'],
        duration: json['duration'],
        teachersIds: List.from(json['teachersIds']),
        selectedTeacherId: json['selectedTeacherId'],
        dateId: json['dateId'],
        startTime: Tuple2<int, int>(
          json['startTime'][0] as int,
          json['startTime'][1] as int,
        ));
  }

  @override
  toJson() {
    return {
      'id': id,
      'duration': duration,
      'teachersIds': teachersIds,
      'selectedTeacherId': selectedTeacherId,
      'dateId': dateId,
      'startTime': startTime,
    };
  }
}
