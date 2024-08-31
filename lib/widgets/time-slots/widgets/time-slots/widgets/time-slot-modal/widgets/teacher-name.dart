import 'package:flutter/material.dart';
import 'package:touche_app/models/entities/teacher.dart';

class TeacherName extends StatelessWidget {
  final Teacher selectedTeacher;

  const TeacherName({super.key, required this.selectedTeacher});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            selectedTeacher.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
