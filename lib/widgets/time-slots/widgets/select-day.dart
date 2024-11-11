import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSelect extends StatelessWidget {
  final Function(String) daySelected;
  final String selectedDateId;

  const TimeSelect({super.key, required this.daySelected, required this.selectedDateId});

  @override
  Widget build(BuildContext context) {
    final List<DayLabel> days = _generateDays();
    final double width = MediaQuery.of(context).size.width;
    final double dayWidth = width * 0.13;
    final double dayPadding = width * 0.01;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                daySelected(days[index].id);
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      days[index].dayName.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(dayPadding, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: days[index].id == selectedDateId ? Colors.orange[700] : Colors.transparent,
                        ),
                        width: dayWidth,
                        child: Center(
                          child: Text(
                            days[index].dayNumber.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<DayLabel> _generateDays({int count = 30}) {
    DateTime now = DateTime.now();
    final List<DayLabel> dayLabels = [];

    for (var i = 0; i <= count; i++) {
      dayLabels.add(DayLabel(now));

      now = now.add(const Duration(days: 1));
    }

    return dayLabels;
  }
}

class DayLabel {
  late String id;
  late int year;
  late String dayName;
  late int dayNumber;
  late int monthNumber;

  DayLabel(DateTime dateTime) {
    dayName = DateFormat('EEE').format(dateTime);
    dayNumber = int.parse(DateFormat('dd').format(dateTime));
    monthNumber = int.parse(DateFormat('MM').format(dateTime));
    year = int.parse(DateFormat('yyyy').format(dateTime));
    id = '$dayNumber-$monthNumber-$year';
  }

  bool isToday() {
    final DateTime currentDate = DateTime.now();
    final int currentMonthNumber = int.parse(DateFormat('MM').format(currentDate));
    final int currentDayNumber = int.parse(DateFormat('dd').format(currentDate));
    final int year = int.parse(DateFormat('yyyy').format(currentDate));

    return dayNumber == currentDayNumber && monthNumber == currentMonthNumber && year == year;
  }
}
