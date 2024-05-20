import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touche_app/widgets/shared/widgets/network-image.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';

class TeacherImageSwitcher extends StatefulWidget {
  const TeacherImageSwitcher({super.key});

  @override
  _TeacherImageSwitcherState createState() => _TeacherImageSwitcherState();
}

class _TeacherImageSwitcherState extends State<TeacherImageSwitcher> {
  final CarouselController _controller = CarouselController();
  late TimeSlotModalModel model;

  @override
  void initState() {
    super.initState();

    model = Provider.of<TimeSlotModalModel>(context, listen: false);

    model.addListener(_onSelectedTeacherIndexChanged);
  }

  void _onSelectedTeacherIndexChanged() {
    _controller.jumpToPage(model.selectedTeacherIndex);
  }

  @override
  void dispose() {
    model.removeListener(_onSelectedTeacherIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeSlotModalModel>(
      builder: (context, model, child) {
        return CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
                enlargeCenterPage: true,
                disableCenter: true,
                enableInfiniteScroll: false,
                pageSnapping: true,
                initialPage: model.selectedTeacherIndex,
                onPageChanged: (index, reason) {
                  model.selectTeacher(model.fetchedTeachers[index].id);
                }),
            items: model.fetchedTeachers.map(
              (teacher) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: UrlImage(imageUrl: teacher.imageUrl));
              },
            ).toList());
      },
    );
  }
}
