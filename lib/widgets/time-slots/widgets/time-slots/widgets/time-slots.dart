import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/shared/widgets/loading.dart';
import 'package:touche_app/widgets/time-slots/widgets/location.dart';
import 'package:touche_app/widgets/time-slots/widgets/select-day.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/state/time-slots.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/time-slot-modal.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slots-list.dart';

class TimeSlots extends StatelessWidget {
  const TimeSlots({super.key});

  void _showCustomModalBottomSheet(BuildContext context, TimeSlot timeSlot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return TimeSlotModal(
          timeSlot: timeSlot,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  ChangeNotifierProvider(
                      create: (context) => locator.get<TimeSlotsModel>(),
                      child: Consumer<TimeSlotsModel>(builder: (context, timeSlotsModel, child) {
                        if (timeSlotsModel.state['loading']) {
                          return const Center(child: Loading());
                        }

                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LocationSelect(
                                  locations: timeSlotsModel.state['locations'],
                                  onLocationSelected: (Location location) => timeSlotsModel.selectLocation(location)),
                            ),
                            TimeSelect(
                                selectedDateId: timeSlotsModel.state['selectedDateId'] as String,
                                daySelected: (String dateId) => timeSlotsModel.selectDateId(dateId)),
                            TimeSlotsList(
                              timeSlots: timeSlotsModel.state['timeSlots'],
                              onCardTapped: _showCustomModalBottomSheet,
                            ),
                          ],
                        );
                      })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
