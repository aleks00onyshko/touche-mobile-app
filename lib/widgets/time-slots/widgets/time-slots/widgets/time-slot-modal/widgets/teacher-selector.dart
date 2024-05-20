import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';

class TeacherSelector extends StatelessWidget {
  const TeacherSelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeSlotModalModel>(builder: (context, model, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: model.selectedTeacherIndex != 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => model.selectPreviousTeacher(),
            ),
          ),
          Center(
            child: Text(
              model.fetchedTeachers[model.selectedTeacherIndex].displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Visibility(
            visible: model.selectedTeacherIndex != model.fetchedTeachers.length - 1,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => model.selectNextTeacher(),
            ),
          ),
        ],
      );
    });
  }
}
