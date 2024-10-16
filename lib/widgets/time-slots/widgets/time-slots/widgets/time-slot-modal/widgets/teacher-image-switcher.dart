import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/widgets/shared/widgets/network-image.dart';

class TeacherImageSwitcher extends StatefulWidget {
  final List<Teacher> teachers;
  final Teacher selectedTeacher;
  final Function selectedTeacherChanged;
  final bool booked;

  const TeacherImageSwitcher(
      {super.key,
      required this.selectedTeacher,
      required this.selectedTeacherChanged,
      required this.teachers,
      required this.booked});

  @override
  _TeacherImageSwitcherState createState() => _TeacherImageSwitcherState();
}

class _TeacherImageSwitcherState extends State<TeacherImageSwitcher> {
  final CarouselControllerPlus _controller = CarouselControllerPlus();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        controller: _controller,
        options: CarouselOptions(
            enlargeCenterPage: true,
            disableCenter: true,
            enableInfiniteScroll: false,
            pageSnapping: true,
            initialPage: _getSelectedTeacherIndex(widget.teachers, widget.selectedTeacher),
            onPageChanged: (index, reason) {
              if (reason == CarouselPageChangedReason.manual) {
                widget.selectedTeacherChanged(widget.teachers[index]);
              }
            }),
        items: (widget.booked ? [widget.selectedTeacher] : widget.teachers).map(
          (teacher) {
            return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: UrlImage(imageUrl: teacher.backgroundImageUrl));
          },
        ).toList());
  }

  int _getSelectedTeacherIndex(List<Teacher> teachers, Teacher selectedTeacher) {
    return teachers.indexWhere((teacher) => teacher.id == selectedTeacher.id);
  }
}
