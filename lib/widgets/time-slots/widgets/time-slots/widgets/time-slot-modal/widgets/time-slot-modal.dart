import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/shared/widgets/loading.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/teacher-image-switcher.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/widgets/teacher-selector.dart';

class TimeSlotModal extends StatelessWidget {
  final TimeSlot timeSlot;

  const TimeSlotModal({
    Key? key,
    required this.timeSlot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeSlotModalModel>.value(
      value: locator.get<TimeSlotModalModel>(
        param1: locator.get<TimeSlotModalDataProvider>(),
        param2: timeSlot,
      ),
      child: Consumer<TimeSlotModalModel>(
        builder: (context, model, child) {
          if (model.loading) {
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
                        flexibleSpace: const FlexibleSpaceBar(
                          background: TeacherImageSwitcher(),
                          collapseMode: CollapseMode.parallax,
                          stretchModes: [StretchMode.zoomBackground],
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [TeacherSelector()],
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
