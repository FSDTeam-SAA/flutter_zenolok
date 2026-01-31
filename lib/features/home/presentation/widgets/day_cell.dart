import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/calendar_event.dart';
import 'calendar_helpers.dart';
import 'event_row.dart';
import 'streak_bar.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.inStreak,
    required this.events,
    required this.dateAreaHeight,
    required this.todayRingDiameter,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool inStreak;
  final List<CalendarEvent> events;

  final double dateAreaHeight;
  final double todayRingDiameter;

  @override
  Widget build(BuildContext context) {
    final isSunday = day.weekday == DateTime.sunday;

    final streaks = events.where(CalendarHelpers.isMultiDayAllDay).toList();
    final CalendarEvent? streak = streaks.isNotEmpty ? streaks.first : null;

    final dayEvents = events.where((e) => !CalendarHelpers.isMultiDayAllDay(e)).toList();

    final bool isStreakStart =
        streak != null && CalendarHelpers.dateOnly(day).isAtSameMomentAs(CalendarHelpers.dateOnly(streak.start));
    final bool hasGreyCard = dayEvents.isNotEmpty || isStreakStart;

    final numberColor = isSunday
        ? const Color(0xFFFF5757)
        : const Color(0xFF212121);

    const double cardInsetV = 1.0;
    const double cardInsetH = 0.6;
    const double streakHeight = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: cardInsetV,
            horizontal: cardInsetH,
          ),
          decoration: hasGreyCard
              ? BoxDecoration(
                  color: const Color(0xFFE0E1E3),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // DATE AREA
              SizedBox(
                height: dateAreaHeight,
                child: Center(
                  child: Container(
                    width: todayRingDiameter,
                    height: todayRingDiameter,
                    alignment: Alignment.center,
                    decoration: () {
                      if (isSelected) {
                        return const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE6EAF0),
                        );
                      }
                      if (isToday) {
                        return BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4C9BFF),
                            width: 1.5,
                          ),
                        );
                      }
                      return null;
                    }(),
                    child: Text(
                      '${day.day}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dongle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 16 / 20,
                        letterSpacing: 0,
                        color: numberColor,
                      ),
                    ),
                  ),
                ),
              ),

              if (streak != null)
                SizedBox(
                  height: streakHeight,
                  child: StreakBar(event: streak, day: day),
                ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final available = constraints.maxHeight;
                      final maxRows = 3;
                      final rowGap = 1.3;
                      final rowH = max(
                        6.0,
                        (available - rowGap * (maxRows - 1)) / maxRows,
                      );

                      final totalEvents = dayEvents.length;
                      final eventsToShow = min(totalEvents, maxRows);
                      final hasOverflow = totalEvents > maxRows;

                      final children = <Widget>[];
                      for (int i = 0; i < eventsToShow; i++) {
                        final e = dayEvents[i];
                        final indicatorColors = <Color>[
                          const Color(0xFF3AA1FF),
                          const Color(0xFF4CAF50),
                          const Color(0xFFFF5757),
                          const Color(0xFFFFC542),
                          const Color(0xFFB47AEA),
                        ];

                        children.add(
                          EventRow(
                            e: e,
                            height: rowH,
                            indicatorColor: indicatorColors[i % indicatorColors.length],
                          ),
                        );

                        if (i < eventsToShow - 1) {
                          children.add(SizedBox(height: rowGap));
                        }
                      }

                      if (hasOverflow) {
                        children.add(
                          SizedBox(
                            height: rowH,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '+3',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  height: 16 / 8,
                                  letterSpacing: -0.32,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
