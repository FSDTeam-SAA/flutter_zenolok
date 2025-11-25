import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/searchScreen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'allday_screen.dart';
import 'chat_screen.dart';
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
    final sample = <CalendarEvent>[
      // add initial data here if you want
    ];

    for (final e in sample) {
      final k = _dOnly(e.start);
      _store.putIfAbsent(k, () => []).add(e);
    }
  }

  Iterable<CalendarEvent> _allEvents() => _store.values.expand((v) => v);

  List<CalendarEvent> _eventsFor(DateTime day) {
    final k = _dOnly(day);
    final exact = _store[k] ?? const <CalendarEvent>[];

    // all-day streaks that cover this day, in insertion order
    final spanning = _allEvents().where(
          (e) => e.allDay && e.end != null && _betweenIncl(day, e.start, e.end!),
    );

    // merge while preserving order of insertion
    final merged = <CalendarEvent>[];
    merged.addAll(exact);
    for (final e in spanning) {
      if (!merged.contains(e)) {
        merged.add(e);
      }
    }



    if (_filters.length == EventCategory.values.length) return merged;
    return merged.where((e) => _filters.contains(e.category)).toList();
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

    final cellGapV = max(8.0, rowHeight * 0.3);
    final cellGapH = 2.0;
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
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              final tween =
                              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  final tween =
                                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              final tween =
                              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
                    selectedDayPredicate: (d) => _selected != null && _dOnly(d) == _selected,
                    onDaySelected: (sel, foc) => setState(() {
                      _selected = _dOnly(sel);
                      _focused.value = foc;
                    }),
                    rowHeight: rowHeight,
                    daysOfWeekHeight: dowHeight,
                    eventLoader: _eventsFor,
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
                      selectedTextStyle: const TextStyle(color: Colors.black),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isSunday ? const Color(0xFFFF5757) : Colors.black54,
                            ),
                          ),
                        );
                      },
                      markerBuilder: (context, day, events) => const SizedBox.shrink(),
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
                    const Spacer(),
                    _GhostPill(
                      label: 'TODAY',
                      icon: Icons.refresh_rounded,
                      onTap: () => setState(() {
                        _focused.value = DateTime.now();
                        _selected = _dOnly(DateTime.now());
                      }),
                    ),
                    const SizedBox(width: 10,),
                    _WhiteRoundPlus(
                      initialDate: _selected ?? DateTime.now(),
                      onAdd: (e) => _addEvent(e),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFEAECEE)),

              // day’s events list
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

/// ---------------------------------------------------------------------------
/// FILTER BAR
/// ---------------------------------------------------------------------------

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
            color: selected ? (bg ?? const Color(0xFFEFF3F9)) : const Color(0xFFF6F7FB),
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

    final showLabel = isStart;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D6),
        borderRadius: borderRadius,
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
  final bool inStreak;
  final List<CalendarEvent> events;

  final double dateAreaHeight;
  final double streakInset;
  final double todayRingDiameter;

  @override
  Widget build(BuildContext context) {
    final isSunday = day.weekday == DateTime.sunday;

    final streaks = events.where((e) => e.allDay && e.end != null).toList();
    final CalendarEvent? streak = streaks.isNotEmpty ? streaks.first : null;

    final dayEvents = events.where((e) => !(e.allDay && e.end != null)).toList();

    final bool isStreakStart =
        streak != null && _dOnly(day).isAtSameMomentAs(_dOnly(streak.start));
    final bool hasGreyCard = dayEvents.isNotEmpty || isStreakStart;

    final numberColor = isSunday ? const Color(0xFFFF5757) : Colors.black;

    const double cardInsetV = 1.0;
    const double cardInsetH = 1.0;
    const double streakHeight = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: cardInsetV,
            horizontal: streak != null ? 0 : cardInsetH,
          ),
          decoration: hasGreyCard
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
                    width: todayRingDiameter,
                    height: todayRingDiameter,
                    alignment: Alignment.center,
                    decoration: () {
                      if (isSelected) {
                        // filled circle for selected day
                        return const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE6EAF0),
                        );
                      }
                      if (isToday) {
                        // ring for "today"
                        return BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4C9BFF),
                            width: 1.5,
                          ),
                        );
                      }
                      return null; // normal day, no background
                    }(),
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


              // STREAK ROW
              if (streak != null)
                SizedBox(
                  height: streakHeight,
                  child: _StreakBar(event: streak, day: day),
                ),

              // EVENTS + "3+"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
                  child: dayEvents.isEmpty
                      ? const SizedBox.shrink()
                      : LayoutBuilder(
                    builder: (context, evConstraints) {
                      final available = max(0.0, evConstraints.maxHeight);

                      const rowGap = 2.0;
                      const maxVisibleRows = 3;
                      const maxVisibleEventsWhenOverflow = 2;

                      final totalEvents = dayEvents.length;
                      final hasOverflow = totalEvents > maxVisibleRows;

                      final eventsToShow = hasOverflow
                          ? maxVisibleEventsWhenOverflow
                          : min(maxVisibleRows, totalEvents);

                      final rows = hasOverflow ? maxVisibleRows : eventsToShow;

                      if (rows == 0) {
                        return const SizedBox.shrink();
                      }

                      final rowH =
                          max(0.0, (available - rowGap * max(0, rows - 1)) / rows) * 0.98;

                      final children = <Widget>[];

                      if (!hasOverflow) {
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(_EventRow(
                            e: dayEvents[i],
                            height: rowH,
                            indicatorColor:
                            _indicatorColors[i % _indicatorColors.length],
                          ));
                          if (i != eventsToShow - 1) {
                            children.add(const SizedBox(height: rowGap));
                          }
                        }
                      } else {
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(_EventRow(
                            e: dayEvents[i],
                            height: rowH,
                            indicatorColor:
                            _indicatorColors[i % _indicatorColors.length],
                          ));
                          children.add(const SizedBox(height: rowGap));
                        }

                        children.add(
                          SizedBox(
                            height: rowH,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '3+',
                                style: TextStyle(
                                  fontSize: min(12.0, rowH * 0.9),
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
    final fs = min(12.0, max(9.0, height * 0.9));
    final barHeight = fs ; // slightly taller than the text

    return SizedBox(
      // height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: barHeight, // ← use barHeight instead of height
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
/// EVENT LIST PANE
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
      for (final e in streaks) _StreakTile(event: e),
      for (final e in allDaySingles) _AllDayTile(event: e),
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

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return _BaseEventCard(
      marginTop: 10,
      child: Row(
        children: [
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatScreen(event: event),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween =
                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
                const Positioned(
                  right: -6,
                  top: -6,
                  child: _Badge(number: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: Colors.black26,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AllDayScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
          // main row
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
              // bar + title
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(event: event),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 18,
                              color: Colors.black45,
                            ),
                            if (event.checklist.isNotEmpty)
                              const Positioned(
                                right: -6,
                                top: -6,
                                child: _Badge(number: 2),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 18,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

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
                color: checked ? const Color(0xFF18A957) : Colors.black26,
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
/// FULL-SCREEN EDITOR + CUSTOM DATE/TIME PICKERS
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

  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 0, minute: 0);

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

  Future<void> _openDateRangePicker() async {
    final result = await showModalBottomSheet<_DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DateRangeBottomSheet(
        initialStart: _startDate,
        initialEnd: _multiDay ? _endDate : null,
      ),
    );

    if (result != null) {
      // You can also inspect result.days (all selected days) here.
      setState(() {
        _startDate = _dOnly(result.start);
        _endDate = _dOnly(result.end);
        _multiDay = !_startDate.isAtSameMomentAs(_endDate);
      });
    }
  }

  Future<void> _openTimeRangePicker() async {
    final result = await showModalBottomSheet<_TimeRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimeRangeBottomSheet(
        initialStart: _startTime,
        initialEnd: _endTime,
      ),
    );

    if (result != null) {
      setState(() {
        _startTime = result.start;
        _endTime = result.end;
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
    const labelColor = Color(0xFFB8BBC5);
    const dividerColor = Color(0xFFE5E6EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF8E8E93),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFF4B5C),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.check_rounded,
              color: Color(0xFF3AC3FF),
            ),
            onPressed: _save,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            // title
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD1D3DA),
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.share,
                    size: 18,
                    color: Color(0xFFC7CAD3),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 4),

            // labels row
            Row(
              children: const [
                _CategoryMarker(color: Color(0xFF3AA1FF)),
                SizedBox(width: 4),
                Text(
                  'Family Dinner  ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF848892),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _CategoryMarker(color: Color(0xFFFFC542)),
                SizedBox(width: 8),
                Text(
                  'Formula submission',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF848892),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // category chips
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: Color(0xFFD0D3DB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in EventCategory.values)
                        _CategoryPill(
                          label: c.label,
                          color: c.color,
                          selected: _category == c,
                          onTap: () => setState(() => _category = c),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // date row
            _EditorRow(
              icon: Icons.event_outlined,
              label: DateFormat('EEE, MMM d, yyyy').format(_startDate),
              labelColor: Colors.black,
              trailing: _multiDay
                  ? Text(
                '—  ${DateFormat('EEE, MMM d, yyyy').format(_endDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
                  : null,
              onTap: _openDateRangePicker,
            ),
            const Divider(color: dividerColor, height: 16),

            // time row
            _EditorRow(
              icon: Icons.access_time_rounded,
              label: DateFormat('hh : mm a').format(_combine(_startDate, _startTime)),
              labelColor: Colors.black,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '—  ${DateFormat('hh : mm a').format(_combine(_startDate, _endTime))}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AllDayPill(
                    value: _allDay,
                    onChanged: (v) => setState(() {
                      _allDay = v;
                      if (!_allDay) _multiDay = false;
                    }),
                  ),
                ],
              ),
              onTap: !_allDay ? _openTimeRangePicker : null,
            ),
            const Divider(color: dividerColor, height: 16),

            // location
            _EditorRow(
              icon: Icons.place_outlined,
              label: 'Location',
              labelColor: labelColor,
              expandMiddle: true,
              middleChild: TextField(
                controller: _location,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: 'Location',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),

            _TodoBubble(
              todos: _todos,
              newTodoController: _newTodo,
              onRemove: (i) => setState(() => _todos.removeAt(i)),
              onSubmit: (v) {
                final t = v.trim();
                if (t.isEmpty) return;
                setState(() {
                  _todos.add('[ ] $t');
                  _newTodo.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock_outline_rounded,
                      size: 16, color: labelColor),
                  SizedBox(width: 4),
                  Text(
                    "Let's JAM",
                    style: TextStyle(
                      fontSize: 13,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: labelColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMarker extends StatelessWidget {
  const _CategoryMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _EditorRow extends StatelessWidget {
  const _EditorRow({
    required this.icon,
    required this.label,
    required this.labelColor,
    this.trailing,
    this.onTap,
    this.expandMiddle = false,
    this.middleChild,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool expandMiddle;
  final Widget? middleChild;

  @override
  Widget build(BuildContext context) {
    final middle = middleChild ??
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: labelColor),
            const SizedBox(width: 12),
            if (expandMiddle) Expanded(child: middle) else middle,
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color.withOpacity(0.12) : Colors.white;
    final border = color.withOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _AllDayPill extends StatelessWidget {
  const _AllDayPill({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEDF5FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE1E3EC),
          ),
        ),
        child: Text(
          'All day',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: value ? const Color(0xFF4A87FF) : const Color(0xFFB8BBC5),
          ),
        ),
      ),
    );
  }
}

class _TodoBubble extends StatelessWidget {
  const _TodoBubble({
    required this.todos,
    required this.newTodoController,
    required this.onRemove,
    required this.onSubmit,
  });

  final List<String> todos;
  final TextEditingController newTodoController;
  final void Function(int index) onRemove;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    const hint = Color(0xFFDBDBDB);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TextField(
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'New todo',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 12,
                color: hint,
              ),
            ),
            style: TextStyle(fontSize: 12),
            maxLines: 2,
            minLines: 1,
          ),
          SizedBox(height: 8),
          Divider(height: 1, color: Color(0xFFE5E5E5)),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'New notes',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 12,
                color: hint,
              ),
            ),
            style: TextStyle(fontSize: 12),
            maxLines: 2,
            minLines: 1,
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HELPER RESULTS
/// ---------------------------------------------------------------------------

class _TimeRangeResult {
  final TimeOfDay start;
  final TimeOfDay end;
  _TimeRangeResult({required this.start, required this.end});
}

class _DateRangeResult {
  /// All selected days (normalized to yyyy-mm-dd and sorted).
  final List<DateTime> days;

  _DateRangeResult({required List<DateTime> days})
      : days = days.map(_dOnly).toList()
    ..sort((a, b) => a.compareTo(b));

  /// Convenience for existing code – first & last selected day.
  DateTime get start => days.first;
  DateTime get end => days.last;
}

/// ---------------------------------------------------------------------------
/// TIME RANGE BOTTOM SHEET  (custom keypad, centered, no overflow)
/// ---------------------------------------------------------------------------

class _TimeRangeBottomSheet extends StatefulWidget {
  const _TimeRangeBottomSheet({
    required this.initialStart,
    required this.initialEnd,
  });

  final TimeOfDay initialStart;
  final TimeOfDay initialEnd;

  @override
  State<_TimeRangeBottomSheet> createState() => _TimeRangeBottomSheetState();
}

class _TimeRangeBottomSheetState extends State<_TimeRangeBottomSheet> {
  static const _accent = Color(0xFFFF6B6B);

  bool _editingStart = true;
  late String _startDigits;
  late String _endDigits;
  late bool _startIsPm;
  late bool _endIsPm;

  @override
  void initState() {
    super.initState();
    // Start with empty digits so keypad always works immediately
    _startDigits = '';
    _endDigits = '';
    _startIsPm = widget.initialStart.period == DayPeriod.pm;
    _endIsPm = widget.initialEnd.period == DayPeriod.pm;
  }

  TimeOfDay _digitsToTime(
      String digits,
      bool isPm,
      TimeOfDay fallback,
      ) {
    // If user didn’t type anything, keep the original time
    if (digits.isEmpty) return fallback;

    if (digits.length < 4) digits = digits.padRight(4, '0');
    int h = int.tryParse(digits.substring(0, 2)) ?? 0;
    int m = int.tryParse(digits.substring(2, 4)) ?? 0;

    h = h.clamp(1, 12);
    m = m.clamp(0, 59);

    int hour24;
    if (isPm) {
      hour24 = (h % 12) + 12;
    } else {
      hour24 = h % 12;
    }

    return TimeOfDay(hour: hour24, minute: m);
  }

  void _onDigitTap(int digit) {
    setState(() {
      if (_editingStart) {
        if (_startDigits.length < 4) {
          _startDigits += digit.toString();
        }
      } else {
        if (_endDigits.length < 4) {
          _endDigits += digit.toString();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_editingStart) {
        if (_startDigits.isNotEmpty) {
          _startDigits = _startDigits.substring(0, _startDigits.length - 1);
        }
      } else {
        if (_endDigits.isNotEmpty) {
          _endDigits = _endDigits.substring(0, _endDigits.length - 1);
        }
      }
    });
  }

  void _onClear() {
    setState(() {
      if (_editingStart) {
        _startDigits = '';
      } else {
        _endDigits = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = min(constraints.maxWidth - 32, 360.0);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time_rounded,
                                size: 18, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              'Set time',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _editingStart
                                            ? _accent
                                            : const Color(0xFFB8BBC5),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'End Time',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: !_editingStart
                                            ? _accent
                                            : const Color(0xFFB8BBC5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _editingStart = true),
                                      child: _TimeDigitDisplay(
                                        digits: _startDigits,
                                        isActive: _editingStart,
                                        accent: _accent,
                                        alignRight: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '—',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFB8BBC5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _editingStart = false),
                                      child: _TimeDigitDisplay(
                                        digits: _endDigits,
                                        isActive: !_editingStart,
                                        accent: _accent,
                                        alignRight: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AmPmRow(
                                      isPm: _startIsPm,
                                      accent: _accent,
                                      onChanged: (isPm) => setState(() {
                                        _startIsPm = isPm;
                                      }),
                                      alignRight: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: _AmPmRow(
                                      isPm: _endIsPm,
                                      accent: _accent,
                                      onChanged: (isPm) => setState(() {
                                        _endIsPm = isPm;
                                      }),
                                      alignRight: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _NumberPad(
                                onDigit: _onDigitTap,
                                onBackspace: _onBackspace,
                                onClear: _onClear,
                                accent: _accent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              final start = _digitsToTime(
                                _startDigits,
                                _startIsPm,
                                widget.initialStart,
                              );
                              final end = _digitsToTime(
                                _endDigits,
                                _endIsPm,
                                widget.initialEnd,
                              );
                              Navigator.pop(
                                context,
                                _TimeRangeResult(start: start, end: end),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Apply time',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeDigitDisplay extends StatelessWidget {
  const _TimeDigitDisplay({
    required this.digits,
    required this.isActive,
    required this.accent,
    this.alignRight = false,
  });

  final String digits;
  final bool isActive;
  final Color accent;
  final bool alignRight;

  String _digitOrZero(int index) {
    if (index < 0 || index >= digits.length) return '0';
    return digits[index];
  }

  Widget _bubble(String text, bool filled) {
    final bool highlight = isActive && filled;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
        highlight ? accent.withOpacity(0.18) : const Color(0xFFE5E5E5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: highlight ? accent : const Color(0xFFB8BBC5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d1 = _digitOrZero(0);
    final d2 = _digitOrZero(1);
    final d3 = _digitOrZero(2);
    final d4 = _digitOrZero(3);

    final innerRow = Row(
      mainAxisAlignment:
      alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        _bubble(d1, digits.length >= 1),
        const SizedBox(width: 4),
        _bubble(d2, digits.length >= 2),
        const SizedBox(width: 4),
        const Text(
          ':',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB8BBC5),
          ),
        ),
        const SizedBox(width: 4),
        _bubble(d3, digits.length >= 3),
        const SizedBox(width: 4),
        _bubble(d4, digits.length >= 4),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: innerRow,
    );
  }
}

class _AmPmRow extends StatelessWidget {
  const _AmPmRow({
    required this.isPm,
    required this.accent,
    required this.onChanged,
    this.alignRight = false,
  });

  final bool isPm;
  final Color accent;
  final ValueChanged<bool> onChanged;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final amSelected = !isPm;
    final pmSelected = isPm;

    Widget chip(String label, bool selected, bool pm) {
      return GestureDetector(
        onTap: () => onChanged(pm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? accent : const Color(0xFFB8BBC5),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment:
      alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        chip('AM', amSelected, false),
        const SizedBox(width: 8),
        chip('PM', pmSelected, true),
      ],
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.accent,
  });

  final void Function(int digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Color accent;

  Widget _numButton({int? digit, IconData? icon, String? label, VoidCallback? onTap}) {
    Widget child;
    if (digit != null) {
      child = Text(
        '$digit',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
        ),
      );
    } else if (label != null) {
      child = Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
        ),
      );
    } else {
      child = Icon(
        icon,
        size: 18,
        color: const Color(0xFF8E8E93),
      );
    }

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.4,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: digit == 0 ? accent.withOpacity(0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _numButton(digit: 7, onTap: () => onDigit(7)),
            _numButton(digit: 8, onTap: () => onDigit(8)),
            _numButton(digit: 9, onTap: () => onDigit(9)),
          ],
        ),
        Row(
          children: [
            _numButton(digit: 4, onTap: () => onDigit(4)),
            _numButton(digit: 5, onTap: () => onDigit(5)),
            _numButton(digit: 6, onTap: () => onDigit(6)),
          ],
        ),
        Row(
          children: [
            _numButton(digit: 1, onTap: () => onDigit(1)),
            _numButton(digit: 2, onTap: () => onDigit(2)),
            _numButton(digit: 3, onTap: () => onDigit(3)),
          ],
        ),
        Row(
          children: [
            _numButton(label: 'C', onTap: onClear),
            _numButton(digit: 0, onTap: () => onDigit(0)),
            _numButton(
              icon: Icons.backspace_rounded,
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// DATE RANGE BOTTOM SHEET  (multi-select: year/month → days)
/// ---------------------------------------------------------------------------

enum _DatePickerMode { yearMonth, monthDays }

class _DateRangeBottomSheet extends StatefulWidget {
  const _DateRangeBottomSheet({
    required this.initialStart,
    this.initialEnd,
  });

  final DateTime initialStart;
  final DateTime? initialEnd;

  @override
  State<_DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends State<_DateRangeBottomSheet> {
  static const _accent = Color(0xFFFF6B6B);

  late DateTime _displayMonth;
  late int _baseYear;

  /// All selected days (normalized to Y/M/D).
  late Set<DateTime> _selectedDays;

  _DatePickerMode _mode = _DatePickerMode.yearMonth;

  @override
  void initState() {
    super.initState();

    _selectedDays = <DateTime>{};

    // Initialize from the given start/end as a simple contiguous range.
    final start = _dOnly(widget.initialStart);
    final end = widget.initialEnd != null ? _dOnly(widget.initialEnd!) : start;

    DateTime d = start;
    while (!d.isAfter(end)) {
      _selectedDays.add(d);
      d = d.add(const Duration(days: 1));
    }

    _displayMonth = DateTime(start.year, start.month, 1);
    _baseYear = start.year;
  }

  void _onMonthTap(int year, int month) {
    setState(() {
      _mode = _DatePickerMode.monthDays;
      _displayMonth = DateTime(year, month, 1);
    });
  }

  void _onDayTap(DateTime day) {
    final d = _dOnly(day);
    setState(() {
      if (_selectedDays.contains(d)) {
        _selectedDays.remove(d);
      } else {
        _selectedDays.add(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = min(constraints.maxWidth - 32, 360.0);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined,
                                size: 18, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              'Choose a date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: _mode == _DatePickerMode.yearMonth
                                ? _YearMonthView(
                              key: const ValueKey('yearMonth'),
                              baseYear: _baseYear,
                              selectedDays: _selectedDays,
                              accent: _accent,
                              onMonthTap: _onMonthTap,
                            )
                                : _MonthDaysView(
                              key: const ValueKey('monthDays'),
                              displayMonth: _displayMonth,
                              selectedDays: _selectedDays,
                              accent: _accent,
                              onDayTap: _onDayTap,
                              onMonthChanged: (m) {
                                setState(() {
                                  _displayMonth = m;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              if (_selectedDays.isEmpty) {
                                Navigator.pop(context);
                                return;
                              }
                              final days = _selectedDays.toList()
                                ..sort((a, b) => a.compareTo(b));
                              Navigator.pop(
                                context,
                                _DateRangeResult(days: days),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Apply date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// STEP 1: YEAR + MONTH CIRCLES

class _YearMonthView extends StatelessWidget {
  const _YearMonthView({
    super.key,
    required this.baseYear,
    required this.selectedDays,
    required this.accent,
    required this.onMonthTap,
  });

  final int baseYear;
  final Set<DateTime> selectedDays;
  final Color accent;
  final void Function(int year, int month) onMonthTap;

  bool _hasSelectionForMonth(int year, int month) {
    return selectedDays.any((d) => d.year == year && d.month == month);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildYear(int year) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$year',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF737373),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int month = 1; month <= 12; month++)
                _DateBubble(
                  label: '$month',
                  selectedStart: _hasSelectionForMonth(year, month),
                  selectedEnd: false,
                  inRange: false,
                  accent: accent,
                  onTap: () => onMonthTap(year, month),
                ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildYear(baseYear),
        const SizedBox(height: 16),
        buildYear(baseYear + 1),
      ],
    );
  }
}

/// STEP 2: MONTH CALENDAR WITH DAYS (multi-select)

class _MonthDaysView extends StatefulWidget {
  const _MonthDaysView({
    super.key,
    required this.displayMonth,
    required this.selectedDays,
    required this.accent,
    required this.onDayTap,
    required this.onMonthChanged,
  });

  final DateTime displayMonth;
  final Set<DateTime> selectedDays;
  final Color accent;
  final void Function(DateTime day) onDayTap;
  final void Function(DateTime newMonth) onMonthChanged;

  @override
  State<_MonthDaysView> createState() => _MonthDaysViewState();
}

class _MonthDaysViewState extends State<_MonthDaysView> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.displayMonth;
  }

  bool _isSelected(DateTime day) => widget.selectedDays.contains(_dOnly(day));

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return Column(
      children: [
        // Top row: "< October    Done >"
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left_rounded,
                  size: 22, color: Color(0xFFB8BBC5)),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                });
                widget.onMonthChanged(_focusedDay);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                DateFormat('MMMM').format(_focusedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3A3A),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8BBC5),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_right_rounded,
                  size: 22, color: Color(0xFFB8BBC5)),
              onPressed: () {
                setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                });
                widget.onMonthChanged(_focusedDay);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Calendar grid
        SizedBox(
          height: 260,
          child: TableCalendar(
            firstDay: DateTime(_focusedDay.year - 1, 1, 1),
            lastDay: DateTime(_focusedDay.year + 1, 12, 31),
            focusedDay: _focusedDay,
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarFormat: CalendarFormat.month,
            rowHeight: 34,
            daysOfWeekHeight: 18,
            availableGestures: AvailableGestures.none,
            selectedDayPredicate: (day) => _isSelected(day),
            onPageChanged: (day) {
              setState(() {
                _focusedDay = DateTime(day.year, day.month, 1);
              });
              widget.onMonthChanged(_focusedDay);
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: false,
              defaultTextStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w100,
                color: Color(0xFF808080),
              ),
              weekendTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w100,
                color: Color(0xFF808080),
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w100,
              ),
              cellMargin:
              const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w100,
                color: Color(0xFFFF6B6B), // S red
              ),
              weekdayStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w100,
                color: Color(0xFFB8BBC5),
              ),
            ),
            onDaySelected: (day, _) => widget.onDayTap(day),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final bool isSunday = day.weekday == DateTime.sunday;
                final bool isSelected = _isSelected(day);

                Color bg;
                Color textColor;

                if (isSelected) {
                  bg = accent;
                  textColor = Colors.white;
                } else {
                  bg = const Color(0xFFD5D5D5);
                  textColor =
                  isSunday ? accent : const Color(0xFF707070);
                }

                return Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
              // hide outside days completely
              outsideBuilder: (context, day, focusedDay) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable round bubble (month grid)

class _DateBubble extends StatelessWidget {
  const _DateBubble({
    required this.label,
    required this.selectedStart,
    required this.selectedEnd,
    required this.inRange,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selectedStart;
  final bool selectedEnd;
  final bool inRange;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedStart || selectedEnd;

    Color bg;
    Color textColor;

    if (selected) {
      bg = accent;
      textColor = Colors.white;
    } else if (inRange) {
      bg = accent.withOpacity(0.15);
      textColor = const Color(0xFF555555);
    } else {
      bg = const Color(0xFFD5D5D5);
      textColor = const Color(0xFF555555);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
