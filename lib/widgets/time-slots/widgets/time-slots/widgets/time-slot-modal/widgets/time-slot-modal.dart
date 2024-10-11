import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/shared/widgets/loading.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/book-button.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/teacher-image-switcher.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/teacher-name.dart';

class TimeSlotModal extends StatelessWidget {
  final TimeSlot timeSlot;

  const TimeSlotModal({
    super.key,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeSlotModalModel>.value(
      value: locator.get<TimeSlotModalModel>(
        param1: locator.get<TimeSlotModalDataProvider>(),
        param2: timeSlot,
      ),
      child: Consumer<TimeSlotModalModel>(
        builder: (context, model, child) {
          if (model.state['loading']) {
            return const Center(child: Loading());
          }

          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Stack(
              children: [
                FractionallySizedBox(
                  heightFactor: 0.9,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        expandedHeight: MediaQuery.of(context).size.height * 0.45,
                        flexibleSpace: FlexibleSpaceBar(
                          background: TeacherImageSwitcher(
                            teachers: model.state['teachers'],
                            booked: model.state['booked'],
                            selectedTeacher: model.state['selectedTeacher'],
                            selectedTeacherChanged: (teacher) => {model.changeSelectedTeacher(teacher)},
                          ),
                          collapseMode: CollapseMode.parallax,
                          stretchModes: const [StretchMode.zoomBackground],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TeacherName(selectedTeacher: model.state['selectedTeacher']),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                                child: Text(model.state['selectedTeacher'].description),
                              ),
                              Center(
                                  child: BookButton(
                                      booked: model.state['booked'],
                                      disabled: model.state['bookButtonDisabled'],
                                      onBookTapped: () => model.toggleBookedState())),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
