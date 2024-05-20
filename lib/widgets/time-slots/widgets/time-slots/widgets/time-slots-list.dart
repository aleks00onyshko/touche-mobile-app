import 'package:flutter/material.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot.dart';

class TimeSlotsList extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final Function(BuildContext, TimeSlot) onCardTapped;

  const TimeSlotsList({super.key, required this.timeSlots, required this.onCardTapped});

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(
          child: Text('No classes for today...'),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 250,
      child: ListView.builder(
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = timeSlots[index];
          return GestureDetector(
            onTap: () => onCardTapped(context, timeSlot),
            child: TimeSlotCard(timeSlot: timeSlot),
          );
        },
      ),
    );
  }
}
