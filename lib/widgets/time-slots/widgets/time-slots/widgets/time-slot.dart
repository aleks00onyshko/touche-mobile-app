import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots.model.dart';

class TimeSlotCard extends StatelessWidget {
  final TimeSlot timeSlot;

  const TimeSlotCard({super.key, required this.timeSlot});

  // TODO: refactor, so it will just only accept teachers;
  @override
  Widget build(BuildContext context) {
    return Consumer<TimeSlotsModel>(builder: (context, timeSlotsModel, child) {
      final List<Teacher> teachers = timeSlotsModel.teachers;
      final Teacher teacher = teachers.where((teacher) => teacher.id == timeSlot.teachersIds[0]).toList().first;

      return SizedBox(
        height: 110,
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Piano',
                      style: TextStyle(fontSize: 25),
                    ),
                    Text(timeSlot.startTime.toList().join(':'))
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(teacher.displayName.toUpperCase()),
                      Text(
                        '${timeSlot.duration.toString()} min',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
