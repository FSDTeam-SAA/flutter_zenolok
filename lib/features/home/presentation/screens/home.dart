
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/searchScreen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'notification_screen.dart';


/// colors for the left indicators inside day cells (per-row)
const _indicatorColors = <Color>[
  Color(0xFF3AA1FF), // blue
  Color(0xFF4CAF50), // green
  Color(0xFFFF5757), // red
  Color(0xFFFFC542), // yellow
  Color(0xFFB47AEA), // purple
];

/// ---------------------------------------------------------------------------
/// DOMAIN
/// ---------------------------------------------------------------------------

enum EventCategory { home, work, school, personal }

extension EventCategoryX on EventCategory {
  String get label => switch (this) {
    EventCategory.home => 'Home',
    EventCategory.work => 'Work',
    EventCategory.school => 'School',
    EventCategory.personal => 'Personal',
  };

  IconData get icon => switch (this) {
    EventCategory.home => Icons.home_rounded,
    EventCategory.work => Icons.work_rounded,
    EventCategory.school => Icons.school_rounded,
    EventCategory.personal => Icons.person_rounded,
  };

  Color get color => switch (this) {
    EventCategory.home => const Color(0xFF3AA1FF),
    EventCategory.work => const Color(0xFFFFC542),
    EventCategory.school => const Color(0xFFB47AEA),
    EventCategory.personal => const Color(0xFF4CAF50),
  };

  Color get pastel => switch (this) {
    EventCategory.home => const Color(0xFFEAF3FF),
    EventCategory.work => const Color(0xFFFFF5D6),
    EventCategory.school => const Color(0xFFF3E9FF),
    EventCategory.personal => const Color(0xFFE9F7EF),
  };
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end; // when set + allDay => multi-day “streak”
  final bool allDay;
  final String? location;
  final EventCategory category;
  final List<String> checklist;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.allDay = false,
    this.location,
    required this.category,
    this.checklist = const [],
  });
}

DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _betweenIncl(DateTime x, DateTime a, DateTime b) {
  final dx = _dOnly(x), da = _dOnly(a), db = _dOnly(b);
  return (dx.isAtSameMomentAs(da) || dx.isAfter(da)) &&
      (dx.isAtSameMomentAs(db) || dx.isBefore(db));
}

/// ---------------------------------------------------------------------------
/// PAGE
/// ---------------------------------------------------------------------------

class CalendarHomePage extends StatefulWidget {
  const CalendarHomePage({super.key});
  @override
  State<CalendarHomePage> createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  final ValueNotifier<DateTime> _focused = ValueNotifier(DateTime.now());
  DateTime? _selected = _dOnly(DateTime.now());
  CalendarFormat _format = CalendarFormat.month;

  double _scale = 1.0;
  double _baseScale = 1.0;

  final Map<DateTime, List<CalendarEvent>> _store = {};
  final Set<EventCategory> _filters = {
    EventCategory.home,
    EventCategory.work,
    EventCategory.school,
    EventCategory.personal,
  };

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  void _seed() {
    // initial sample data if needed
    final now = DateTime.now();
    final y = now.year, m = now.month;
    DateTime d(int dd) => DateTime(y, m, dd);

    final sample = <CalendarEvent>[

    ];

    for (final e in sample) {
      final k = _dOnly(e.start);
      _store.putIfAbsent(k, () => []).add(e);
    }
  }

  Iterable<CalendarEvent> _allEvents() => _store.values.expand((v) => v);

  List<CalendarEvent> _eventsFor(DateTime day) {
    final k = _dOnly(day);
    final exact = _store[k] ?? [];
    final spanning = _allEvents().where(
          (e) => e.allDay && e.end != null && _betweenIncl(day, e.start, e.end!),
    );
    final all = {...exact, ...spanning}.toList();
    if (_filters.length == EventCategory.values.length) return all;
    return all.where((e) => _filters.contains(e.category)).toList();
  }

  bool _isStreakDay(DateTime day) =>
      _allEvents().any((e) => e.allDay && e.end != null && _betweenIncl(day, e.start, e.end!));

  void _addEvent(CalendarEvent e) {
    final k = _dOnly(e.start);
    setState(() => _store.putIfAbsent(k, () => []).add(e));
  }

  TextStyle get _monthBig =>
      const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 2);
  TextStyle get _yearLight =>
      const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? _dOnly(DateTime.now());

    final rowHeight = (90.0 * _scale).clamp(58.0, 96.0);
    final dowHeight = (50.0 * _scale).clamp(20.0, 36.0);

    final dateAreaHeight = rowHeight * 0.25;
    final streakInset = rowHeight * 0.34;
    final dateDia = rowHeight * 0.58;

    final cellGapV = max(8.0, rowHeight * 0.3); // <- more vertical space
    final cellGapH = 10.0;

    final calHeight = dowHeight + rowHeight * 6 + 8;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [


                    Text(
                      DateFormat('MMM').format(_focused.value).toUpperCase(),
                      style: _monthBig,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy').format(_focused.value),
                      style: _yearLight,
                    ),
                    const Spacer(),


                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const MinimalSearchScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // from right
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              final tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, color: Colors.black),
                    ),



                    Stack(
                      children: [


                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const NotificationScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // from right
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  final tween = Tween(begin: begin, end: end).chain(
                                    CurveTween(curve: curve),
                                  );

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_rounded, color: Colors.black),
                        ),

                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5757),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),



                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // from right
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              final tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_rounded, color: Colors.black),
                    ),


                  ],
                ),
              ),

              // Filter chips row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: _FilterBar(
                  active: _filters,
                  onChange: (newSet) => setState(() => _filters
                    ..clear()
                    ..addAll(newSet)),
                ),
              ),

              // Calendar
              GestureDetector(
                onScaleStart: (d) => _baseScale = _scale,
                onScaleUpdate: (d) =>
                    setState(() => _scale = (_baseScale * d.scale).clamp(.9, 1.4)),
                child: SizedBox(
                  height: calHeight,
                  child: TableCalendar<CalendarEvent>(
                    firstDay: DateTime.utc(2015, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focused.value,
                    onPageChanged: (d) => setState(() => _focused.value = d),
                    headerVisible: false,
                    calendarFormat: _format,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (d) =>
                    _selected != null && _dOnly(d) == _selected,
                    onDaySelected: (sel, foc) => setState(() {
                      _selected = _dOnly(sel);
                      _focused.value = foc;
                    }),
                    rowHeight: rowHeight,
                    daysOfWeekHeight: dowHeight,
                    eventLoader: _eventsFor,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle:
                      TextStyle(fontWeight: FontWeight.w800, color: Colors.black54),
                      weekendStyle:
                      TextStyle(fontWeight: FontWeight.w800, color: Colors.grey),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle:
                      const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                      weekendTextStyle:
                      const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4C9BFF), width: 1.5),
                      ),
                      selectedDecoration:
                      const BoxDecoration(color: Colors.transparent),
                      selectedTextStyle: const TextStyle(color: Colors.black),
                      cellMargin: EdgeInsets.symmetric(
                        vertical: cellGapV,
                        horizontal: cellGapH,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) =>
                      const SizedBox.shrink(),
                      defaultBuilder: (context, day, _) => _DayCell(
                        day: day,
                        isToday: _dOnly(day) == _dOnly(DateTime.now()),
                        isSelected: _selected != null && _dOnly(day) == _selected,
                        inStreak: _isStreakDay(day),
                        events: _eventsFor(day),
                        dateAreaHeight: dateAreaHeight,
                        streakInset: streakInset,
                        todayRingDiameter: dateDia,
                      ),
                      selectedBuilder: (context, day, _) => _DayCell(
                        day: day,
                        isToday: _dOnly(day) == _dOnly(DateTime.now()),
                        isSelected: true,
                        inStreak: _isStreakDay(day),
                        events: _eventsFor(day),
                        dateAreaHeight: dateAreaHeight,
                        streakInset: streakInset,
                        todayRingDiameter: dateDia,
                      ),
                      todayBuilder: (context, day, _) => _DayCell(
                        day: day,
                        isToday: true,
                        isSelected: _selected != null && _dOnly(day) == _selected,
                        inStreak: _isStreakDay(day),
                        events: _eventsFor(day),
                        dateAreaHeight: dateAreaHeight,
                        streakInset: streakInset,
                        todayRingDiameter: dateDia,
                      ),
                    ),
                  ),
                ),
              ),

              // TODAY + +
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    _GhostPill(
                      label: 'TODAY',
                      icon: Icons.refresh_rounded,
                      onTap: () => setState(() {
                        _focused.value = DateTime.now();
                        _selected = _dOnly(DateTime.now());
                      }),
                    ),
                    const Spacer(),
                    _WhiteRoundPlus(
                      initialDate: _selected ?? DateTime.now(),
                      onAdd: (e) => _addEvent(e),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFEAECEE)),

              // day’s events list (no Expanded, non-scrollable widget)
              _EventPane(
                day: selected,
                events: _eventsFor(selected),
                onToggle: (id, original, checked) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _oneLetterDow(DateTime dt, Locale? _) =>
      DateFormat('E').format(dt).substring(0, 1).toUpperCase();
}

/// Filter bar row
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active, required this.onChange});
  final Set<EventCategory> active;
  final ValueChanged<Set<EventCategory>> onChange;

  @override
  Widget build(BuildContext context) {
    final allOn = active.length == EventCategory.values.length;

    Widget chip({
      required Widget child,
      required bool selected,
      required VoidCallback onTap,
      Color? bg,
      Color? fg,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (selected ? (bg ?? const Color(0xFFEFF3F9)) : const Color(0xFFF6F7FB)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(.06)),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
            child: child,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(
            child: const Text('All'),
            selected: allOn,
            onTap: () => onChange({...EventCategory.values}),
          ),
          const SizedBox(width: 8),
          for (final c in EventCategory.values) ...[
            chip(
              child: Row(children: [
                Icon(c.icon, size: 14, color: c.color),
                const SizedBox(width: 6),
                Text(c.label),
              ]),
              selected: active.contains(c),
              onTap: () {
                final next = {...active};
                if (next.contains(c)) {
                  next.remove(c);
                  if (next.isEmpty) next.add(c);
                } else {
                  next.add(c);
                }
                onChange(next);
              },
              bg: c.pastel,
              fg: Colors.black,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// DAY CELL
/// ---------------------------------------------------------------------------
///






class _StreakBar extends StatelessWidget {
  const _StreakBar({
    required this.event,
    required this.day,
  });

  final CalendarEvent event;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final d = _dOnly(day);
    final start = _dOnly(event.start);
    final end = _dOnly(event.end!);

    final isStart = d.isAtSameMomentAs(start);
    final isEnd = d.isAtSameMomentAs(end);
    final isSingle = isStart && isEnd;

    final radius = const Radius.circular(8);

    final borderRadius = BorderRadius.only(
      topLeft: (isStart || isSingle) ? radius : Radius.zero,
      bottomLeft: (isStart || isSingle) ? radius : Radius.zero,
      topRight: (isEnd || isSingle) ? radius : Radius.zero,
      bottomRight: (isEnd || isSingle) ? radius : Radius.zero,
    );

    final showLabel = isStart; // only show text on first day of streak

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D6),
        // e.g. yellowish for streak
        // borderRadius: borderRadius,
      ),
      alignment: Alignment.centerLeft,
      child: showLabel
          ? Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: event.category.color,
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.inStreak,
    required this.events,
    required this.dateAreaHeight,
    required this.streakInset,
    required this.todayRingDiameter,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool inStreak; // kept for compatibility, not used directly
  final List<CalendarEvent> events;

  final double dateAreaHeight;
  final double streakInset;
  final double todayRingDiameter;

  @override
  Widget build(BuildContext context) {
    final isSunday = day.weekday == DateTime.sunday;

    // multi-day all-day events (streaks)
    final streaks = events.where((e) => e.allDay && e.end != null).toList();
    final CalendarEvent? streak = streaks.isNotEmpty ? streaks.first : null;

    // normal events (timed + single-day all-day)
    final dayEvents = events.where((e) => !(e.allDay && e.end != null)).toList();

    final hasAnyEvents = dayEvents.isNotEmpty || streak != null;
    final numberColor = isSunday ? const Color(0xFF9E9E9E) : Colors.black;

    // gaps between cards
    const double cardInsetV = 2.0;
    const double cardInsetH = 2.0;

    const double streakHeight = 15.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: cardInsetV,
            horizontal: cardInsetH,
          ),
          decoration: hasAnyEvents
              ? BoxDecoration(
            color: const Color(0xFFE0E1E3),
            borderRadius: BorderRadius.circular(16),
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
                    width: isSelected ? null : todayRingDiameter,
                    height:
                    isSelected ? (dateAreaHeight * 0.7) : todayRingDiameter,
                    padding: isSelected
                        ? const EdgeInsets.symmetric(horizontal: 6)
                        : null,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? BoxDecoration(
                      color: const Color(0xFFE6EAF0),
                      borderRadius: BorderRadius.circular(4),
                    )
                        : (isToday
                        ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4C9BFF),
                        width: 1.5,
                      ),
                    )
                        : null),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: numberColor,
                      ),
                    ),
                  ),
                ),
              ),

              // STREAK ROW (same height/position in every cell)
              if (streak != null)
                SizedBox(
                  height: streakHeight,
                  child: _StreakBar(event: streak, day: day),
                ),

              // EVENTS + "3+" ROW (no overflow)
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(8, 2, 8, 4), // inside card
                  child: dayEvents.isEmpty
                      ? const SizedBox.shrink()
                      : LayoutBuilder(
                    builder: (context, evConstraints) {
                      final available =
                      max(0.0, evConstraints.maxHeight);

                      const rowGap = 2.0;
                      const maxVisibleRows = 3; // total rows in card
                      const maxVisibleEventsWhenOverflow = 2;

                      final totalEvents = dayEvents.length;
                      final hasOverflow =
                          totalEvents > maxVisibleRows; // 4+ events

                      // how many event rows to actually show
                      final eventsToShow = hasOverflow
                          ? maxVisibleEventsWhenOverflow
                          : min(maxVisibleRows, totalEvents);

                      // total rows (event rows + maybe a "3+" row)
                      final rows =
                      hasOverflow ? maxVisibleRows : eventsToShow;

                      if (rows == 0) {
                        return const SizedBox.shrink();
                      }

                      // distribute height between rows + gaps, with tiny slack
                      final rowH = max(
                        0.0,
                        (available -
                            rowGap * max(0, rows - 1)) /
                            rows,
                      ) *
                          0.98;

                      final children = <Widget>[];

                      if (!hasOverflow) {
                        // 1–3 events, no "3+"
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(_EventRow(
                            e: dayEvents[i],
                            height: rowH,
                            indicatorColor: _indicatorColors[
                            i % _indicatorColors.length],
                          ));
                          if (i != eventsToShow - 1) {
                            children.add(const SizedBox(height: rowGap));
                          }
                        }
                      } else {
                        // 4+ events → 2 events + one "3+" row
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(_EventRow(
                            e: dayEvents[i],
                            height: rowH,
                            indicatorColor: _indicatorColors[
                            i % _indicatorColors.length],
                          ));
                          children.add(const SizedBox(height: rowGap));
                        }

                        // third row = "3+"
                        children.add(
                          SizedBox(
                            height: rowH,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '3+',
                                style: TextStyle(
                                  fontSize:
                                  min(12.0, rowH * 0.9), // nice & big
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
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

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.e,
    required this.height,
    this.indicatorColor,
  });

  final CalendarEvent e;
  final double height;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    // bigger but still tied to row height so it doesn't overflow
    final fs = min(13.0, max(9.0, height * 0.9));

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: height,
            decoration: BoxDecoration(
              color: indicatorColor ?? e.category.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 2.5),
          Expanded(
            child: Text(
              e.title,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3A3A3A),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}









/// ---------------------------------------------------------------------------
/// EVENT PANE (now non-scrollable, used inside SingleChildScrollView)
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// EVENT LIST (red area)
/// ---------------------------------------------------------------------------

class _EventPane extends StatelessWidget {
  const _EventPane({
    required this.day,
    required this.events,
    required this.onToggle,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final void Function(String eventId, String item, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    final streaks = events.where((e) => e.allDay && e.end != null).toList();
    final allDaySingles = events.where((e) => e.allDay && e.end == null).toList();
    final timed = events.where((e) => !e.allDay).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final children = <Widget>[
      // 1) streak events
      for (final e in streaks) _StreakTile(event: e),

      // 2) all-day single events
      for (final e in allDaySingles) _AllDayTile(event: e),

      // 3) timed events with checklist
      for (final e in timed)
        _TimedTile(
          event: e,
          onToggle: (item, checked) => onToggle(e.id, item, checked),
        ),

      if (streaks.isEmpty && allDaySingles.isEmpty && timed.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No events yet. Tap “+” to add.',
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

/// Common card container to mimic flat iOS style
class _BaseEventCard extends StatelessWidget {
  const _BaseEventCard({required this.child, this.marginTop = 8});

  final Widget child;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12, marginTop, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ---------------------------------------------------------------------------
/// STREAK ROW
/// ---------------------------------------------------------------------------

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return _BaseEventCard(
      marginTop: 10,
      child: Row(
        children: [
          // left color bar + label
          _LabelWithBar(
            barColor: const Color(0xFFFFC542),
            text: 'Streak',
            textColor: const Color(0xFFDA9A00),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // chat icon with red badge (2)
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: Colors.black45),
              Positioned(
                right: -6,
                top: -6,
                child: _Badge(number: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ALL-DAY ROW
/// ---------------------------------------------------------------------------

class _AllDayTile extends StatelessWidget {
  const _AllDayTile({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return _BaseEventCard(
      child: Row(
        children: [
          _LabelWithBar(
            barColor: const Color(0xFF3AA1FF),
            text: 'All day',
            textColor: const Color(0xFF3AA1FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // grey refresh icon
          const Icon(Icons.refresh_rounded,
              size: 18, color: Colors.black26),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TIMED ROW + CHECKLIST (Body check)
/// ---------------------------------------------------------------------------

class _TimedTile extends StatelessWidget {
  const _TimedTile({required this.event, required this.onToggle});

  final CalendarEvent event;
  final void Function(String item, bool checked) onToggle;

  String _fmt(DateTime t) => DateFormat('h:mm a').format(t);

  @override
  Widget build(BuildContext context) {
    return _BaseEventCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // time column
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fmt(event.start),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    if (event.end != null)
                      Text(
                        _fmt(event.end!),
                        style: TextStyle(
                          color: Colors.black.withOpacity(.45),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // colored bar + title/location
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // vertical indicator
                    Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          if (event.location != null)
                            Text(
                              event.location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // bell with badge + expand chevron up
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded,
                          size: 18, color: Colors.black45),
                      if (event.checklist.isNotEmpty)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: _Badge(number: 2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_up_rounded,
                      size: 18, color: Colors.black45),
                ],
              ),
            ],
          ),

          // checklist
          if (event.checklist.isNotEmpty) const SizedBox(height: 10),
          if (event.checklist.isNotEmpty)
            Column(
              children: [
                for (final raw in event.checklist) ...[
                  _ChecklistRow(
                    raw: raw,
                    onTap: (checked) => onToggle(raw, checked),
                  ),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 4),
                Text(
                  'New todo',
                  style: TextStyle(
                    color: Colors.black.withOpacity(.25),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// one checklist row using round radio-style indicators
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.raw, required this.onTap});

  final String raw;
  final void Function(bool checked) onTap;

  @override
  Widget build(BuildContext context) {
    final checked = raw.startsWith('[x]');
    final label = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '');

    return InkWell(
      onTap: () => onTap(!checked),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: checked
                    ? const Color(0xFF18A957)
                    : Colors.black26,
                width: 1.6,
              ),
              color: checked ? const Color(0xFFE6F6EC) : Colors.transparent,
            ),
            child: checked
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF18A957),
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// left vertical bar + small label ("Streak", "All day")
class _LabelWithBar extends StatelessWidget {
  const _LabelWithBar({
    required this.barColor,
    required this.text,
    this.textColor,
  });

  final Color barColor;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// small red number badge
class _Badge extends StatelessWidget {
  const _Badge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}


class _GhostPill extends StatelessWidget {
  const _GhostPill({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteRoundPlus extends StatelessWidget {
  const _WhiteRoundPlus({required this.initialDate, required this.onAdd});
  final DateTime initialDate;
  final void Function(CalendarEvent e) onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final created = await Navigator.of(context).push<CalendarEvent>(
          MaterialPageRoute(
            builder: (_) => EventEditorScreen(initialDate: initialDate),
            fullscreenDialog: true,
          ),
        );
        if (created != null) onAdd(created);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FULL-SCREEN EDITOR
/// ---------------------------------------------------------------------------

class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({super.key, required this.initialDate});
  final DateTime initialDate;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _newTodo = TextEditingController();
  final List<String> _todos = [];

  EventCategory _category = EventCategory.home;

  DateTime _startDate = _dOnly(DateTime.now());
  DateTime _endDate = _dOnly(DateTime.now());
  bool _allDay = true;
  bool _multiDay = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _startDate = _dOnly(widget.initialDate);
    _endDate = _startDate;
  }

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _newTodo.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
      builder: (c, child) => Theme(
        data: Theme.of(c!).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(surface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = _dOnly(picked);
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = _dOnly(picked);
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked =
    await showTimePicker(context: context, initialTime: isStart ? _startTime : _endTime);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final start = _allDay ? _startDate : _combine(_startDate, _startTime);
    final DateTime? end =
    _allDay ? (_multiDay ? _endDate : null) : _combine(_startDate, _endTime);
    Navigator.pop(
      context,
      CalendarEvent(
        id: UniqueKey().toString(),
        title: _title.text.trim(),
        start: start,
        end: end,
        allDay: _allDay,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        category: _category,
        checklist: _todos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const hint = TextStyle(color: Colors.black54);
    const input = TextStyle(color: Colors.black);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 68,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,color: Colors.red,),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.check,color: Colors.green,),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // title
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(fontSize: 22, color: Colors.black38),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 6),

            // category chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in EventCategory.values)
                  ChoiceChip(
                    selected: _category == c,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 16, color: c.color),
                        const SizedBox(width: 6),
                        Text(c.label, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    selectedColor: c.pastel,
                    onSelected: (_) => setState(() => _category = c),
                    side: BorderSide(color: Colors.black.withOpacity(.08)),
                    backgroundColor: const Color(0xFFF6F7FB),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // date & time section
            _EditorSection(
              icon: Icons.event_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: _OutlinedBtn(
                        text: DateFormat('EEE, MMM d').format(_startDate),
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_allDay && _multiDay)
                      Expanded(
                        child: _OutlinedBtn(
                          text: 'End: ${DateFormat('EEE, MMM d').format(_endDate)}',
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('All day', style: TextStyle(color: Colors.black)),
                          value: _allDay,
                          activeColor: const Color(0xFF18A957),
                          activeTrackColor: const Color(0xFFBDECCB),
                          onChanged: (v) => setState(() {
                            _allDay = v;
                            if (!v) _multiDay = false;
                          }),
                        ),
                      ),
                      if (_allDay)
                        Expanded(
                          child: SwitchListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title:
                            const Text('Multi-day', style: TextStyle(color: Colors.black)),
                            value: _multiDay,
                            activeColor: const Color(0xFF18A957),
                            activeTrackColor: const Color(0xFFBDECCB),
                            onChanged: (v) => setState(() => _multiDay = v),
                          ),
                        ),
                    ],
                  ),
                  if (!_allDay) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: _OutlinedBtn(
                          text: _startTime.format(context),
                          onTap: () => _pickTime(isStart: true),
                          icon: Icons.schedule_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OutlinedBtn(
                          text: _endTime.format(context),
                          onTap: () => _pickTime(isStart: false),
                          icon: Icons.schedule_rounded,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // location
            _EditorSection(
              icon: Icons.place_outlined,
              child: TextField(
                controller: _location,
                style: input,
                decoration: const InputDecoration(
                  hintText: 'Location',
                  hintStyle: hint,
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Todos
            _EditorSection(
              icon: Icons.check_circle_outline_rounded,
              child: Column(
                children: [
                  for (int i = 0; i < _todos.length; i++) ...[
                    Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked,
                            size: 18, color: Colors.black26),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_todos[i], style: input)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _todos.removeAt(i)),
                        ),
                      ],
                    ),
                    if (i != _todos.length - 1) const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: _newTodo,
                    style: input,
                    decoration: const InputDecoration(
                      hintText: 'New todo',
                      hintStyle: hint,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (v) {
                      final t = v.trim();
                      if (t.isEmpty) return;
                      setState(() {
                        _todos.add('[ ] $t');
                        _newTodo.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black38),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.black),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  const _OutlinedBtn({required this.text, required this.onTap, this.icon});
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon ?? Icons.event_rounded, size: 18, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.black.withOpacity(.12)),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
    );
  }
}


/// ---------------------------------------------------------------------------
/// “Red box” area – 3 event rows + todos
/// ---------------------------------------------------------------------------



/// TIMED – “Body check” + small strip + icons
class _TimedEventTile extends StatelessWidget {
  const _TimedEventTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // time & place
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '8:00 AM',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '9:00 AM',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // vertical bar
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              const SizedBox(width: 8),
              // title + location
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body check',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '20, Farm Road',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // notification + more icon & small red badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      size: 18, color: Colors.black38),
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded,
                  size: 18, color: Colors.black26),
            ],
          ),
        ],
      ),
    );
  }
}

/// Radio-style todo list at the bottom
class _TodoRadioList extends StatelessWidget {
  const _TodoRadioList();

  @override
  Widget build(BuildContext context) {
    Widget _row(String label, {bool selected = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF18A957)
                      : Colors.black26,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18A957),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('Medic card'),
        _row('ID card'),
        _row('Insurance Form', selected: true),
      ],
    );
  }
}
