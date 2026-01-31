import 'package:flutter/material.dart';

import '../../data/models/calendar_event.dart';
import 'all_day_tile.dart';
import 'calendar_helpers.dart';
import 'streak_tile.dart';
import 'timed_tile.dart';

class EventPane extends StatelessWidget {
  const EventPane({
    super.key,
    required this.day,
    required this.events,
    required this.onToggle,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final void Function(String eventId, String item, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    final streaks = events.where(CalendarHelpers.isMultiDayAllDay).toList();

    final allDaySingles = events
        .where((e) => e.allDay && !CalendarHelpers.isMultiDayAllDay(e))
        .toList();

    final timed = events.where((e) => !e.allDay).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final children = <Widget>[
      for (final e in streaks) StreakTile(event: e),
      for (final e in allDaySingles) AllDayTile(event: e),
      for (final e in timed)
        TimedTile(
          event: e,
          onToggle: (item, checked) => onToggle(e.id, item, checked),
        ),
      if (streaks.isEmpty && allDaySingles.isEmpty && timed.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No events yet. Tap "+" to add.',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
