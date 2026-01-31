import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/calendar_event.dart';
import 'calendar_helpers.dart';
import 'day_cell.dart';

class CalendarSection extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat format;
  final Function(DateTime) onPageChanged;
  final Function(DateTime, DateTime) onDaySelected;
  final List<CalendarEvent> Function(DateTime) eventLoader;
  final bool Function(DateTime) isStreakDay;

  const CalendarSection({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.format,
    required this.onPageChanged,
    required this.onDaySelected,
    required this.eventLoader,
    required this.isStreakDay,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final rowHeight = (78.0 * _scale).clamp(52.0, 80.0);
    final dowHeight = (22.0 * _scale).clamp(16.0, 24.0);
    final dateAreaHeight = rowHeight * 0.14;
    final dateDia = rowHeight * 0.58;
    final cellGapV = max(8.0, rowHeight * 0.3);
    final cellGapH = 5.0;
    final calHeight = dowHeight + rowHeight * 6;

    return GestureDetector(
      onScaleStart: (d) => _baseScale = _scale,
      onScaleUpdate: (d) => setState(
        () => _scale = (_baseScale * d.scale).clamp(.9, 1.4),
      ),
      child: SizedBox(
        height: calHeight,
        child: TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(0001, 1, 1),
          lastDay: DateTime.utc(3000, 12, 31),
          focusedDay: widget.focusedDay,
          onPageChanged: widget.onPageChanged,
          headerVisible: false,
          calendarFormat: widget.format,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (d) =>
              widget.selectedDay != null &&
              CalendarHelpers.dateOnly(d) == widget.selectedDay,
          onDaySelected: widget.onDaySelected,
          rowHeight: rowHeight,
          daysOfWeekHeight: dowHeight,
          eventLoader: widget.eventLoader,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            weekendTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4C9BFF),
                width: 1.5,
              ),
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.black,
            ),
            cellMargin: EdgeInsets.symmetric(
              vertical: cellGapV,
              horizontal: cellGapH,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text =
                  DateFormat('E').format(day).substring(0, 1).toUpperCase();
              final isSunday = day.weekday == DateTime.sunday;

              return Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    // height: 16 / 14, //  line height 16px
                    letterSpacing: 0,
                    color: isSunday
                        ? const Color(0xFFFF3B30) //  Sunday red
                        : const Color(
                            0xFFB6B5B5,
                          ), //  weekday grey (change if you want)
                  ),
                ),
              );
            },
            markerBuilder: (context, day, events) => const SizedBox.shrink(),
            defaultBuilder: (context, day, _) => DayCell(
              day: day,
              isToday: CalendarHelpers.dateOnly(day) ==
                  CalendarHelpers.dateOnly(DateTime.now()),
              isSelected: widget.selectedDay != null &&
                  CalendarHelpers.dateOnly(day) == widget.selectedDay,
              inStreak: widget.isStreakDay(day),
              events: widget.eventLoader(day),
              dateAreaHeight: dateAreaHeight,
              todayRingDiameter: dateDia,
            ),
            selectedBuilder: (context, day, _) => DayCell(
              day: day,
              isToday: CalendarHelpers.dateOnly(day) ==
                  CalendarHelpers.dateOnly(DateTime.now()),
              isSelected: true,
              inStreak: widget.isStreakDay(day),
              events: widget.eventLoader(day),
              dateAreaHeight: dateAreaHeight,
              todayRingDiameter: dateDia,
            ),
            todayBuilder: (context, day, _) => DayCell(
              day: day,
              isToday: true,
              isSelected: widget.selectedDay != null &&
                  CalendarHelpers.dateOnly(day) == widget.selectedDay,
              inStreak: widget.isStreakDay(day),
              events: widget.eventLoader(day),
              dateAreaHeight: dateAreaHeight,
              todayRingDiameter: dateDia,
            ),
          ),
        ),
      ),
    );
  }
}
