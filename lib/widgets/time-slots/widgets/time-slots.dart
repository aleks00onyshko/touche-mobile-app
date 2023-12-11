import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/state/time-slots.model.dart';
import 'package:touche_app/widgets/shared/widgets/loading.dart';
import 'package:touche_app/widgets/time-slots/widgets/location.dart';
import 'package:touche_app/widgets/time-slots/widgets/select-day.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots-list.dart';

class TimeSlots extends StatelessWidget {
  const TimeSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TimeSlotsModel(),
        child:
            Consumer<TimeSlotsModel>(builder: (context, timeSlotsModel, child) {
          if (timeSlotsModel.loading) {
            return const Center(child: Loading());
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: LocationSelect(
                    locations: timeSlotsModel.locations,
                    onLocationSelected: (Location location) =>
                        timeSlotsModel.selectLocation(location)),
              ),
              TimeSelect(
                  selectedDateId: timeSlotsModel.selectedDateId as String,
                  daySelected: (String dateId) =>
                      timeSlotsModel.selectDateId(dateId)),
              TimeSlotsList(timeSlots: timeSlotsModel.timeSlots)
            ],
          );
        }));
  }
}
