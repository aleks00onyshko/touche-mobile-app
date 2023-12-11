import 'package:touche_app/models/entities/entity.dart';
import 'package:tuple/tuple.dart';

class TimeSlot extends Entity<String> {
  TimeSlot(
      {required String id,
      required this.duration,
      required this.teacherId,
      required this.dateId,
      required this.startTime})
      : super(id);

  late Tuple2<int, int> startTime;
  late int duration;
  late String teacherId;
  late String dateId;
}
