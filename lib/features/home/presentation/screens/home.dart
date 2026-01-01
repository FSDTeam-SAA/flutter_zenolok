import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/searchScreen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/category_filter_bar.dart';
import '../widgets/date_time_widget.dart';
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

enum EventCategory { home, work, school, personal, sport }

extension EventCategoryX on EventCategory {
  String get label => switch (this) {
    EventCategory.home => 'Home',
    EventCategory.work => 'Work',
    EventCategory.school => 'School',
    EventCategory.personal => 'Personal',
    EventCategory.sport => 'Sport',
  };

  IconData get icon => switch (this) {
    EventCategory.home => Icons.home_rounded,
    EventCategory.work => Icons.work_rounded,
    EventCategory.school => Icons.school_rounded,
    EventCategory.personal => Icons.person_rounded,
    EventCategory.sport => Icons.sports_soccer_rounded,
  };

  Color get color => switch (this) {
    EventCategory.home => const Color(0xFF3AA1FF),
    EventCategory.work => const Color(0xFFFFC542),
    EventCategory.school => const Color(0xFFB47AEA),
    EventCategory.personal => const Color(0xFF4CAF50),
    EventCategory.sport => const Color(0xFFFF3366), // pink/red
  };

  Color get pastel => switch (this) {
    EventCategory.home => const Color(0xFFEAF3FF),
    EventCategory.work => const Color(0xFFFFF5D6),
    EventCategory.school => const Color(0xFFF3E9FF),
    EventCategory.personal => const Color(0xFFE9F7EF),
    EventCategory.sport => const Color(0xFFFFE0EB), // light pink
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

  bool _isStreakDay(DateTime day) => _allEvents().any(
        (e) => e.allDay && e.end != null && _betweenIncl(day, e.start, e.end!),
  );

  void _addEvent(CalendarEvent e) {
    final k = _dOnly(e.start);
    setState(() => _store.putIfAbsent(k, () => []).add(e));
  }

  TextStyle get _monthBig => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    letterSpacing: 2,
  );

  TextStyle get _yearLight => const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.black54,
  );

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
    final calHeight = dowHeight + rowHeight * 5;

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
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                            const MinimalSearchScreen(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.black,
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                const NotificationScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.bell,
                            color: Colors.black,
                          ),
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
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                            const SettingsScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: CategoryFilterBar(
                  active: _filters,
                  onChange: (newSet) => setState(() {
                    _filters
                      ..clear()
                      ..addAll(newSet);
                  }),
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
                              color: isSunday
                                  ? const Color(0xFFFF5757)
                                  : Colors.black54,
                            ),
                          ),
                        );
                      },


                      markerBuilder: (context, day, events) =>
                      const SizedBox.shrink(),
                      defaultBuilder: (context, day, _) => _DayCell(
                        day: day,
                        isToday: _dOnly(day) == _dOnly(DateTime.now()),
                        isSelected:
                        _selected != null && _dOnly(day) == _selected,
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
                        isSelected:
                        _selected != null && _dOnly(day) == _selected,
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
                    const SizedBox(width: 10),
                    _WhiteRoundPlus(
                      initialDate: _selected ?? DateTime.now(),
                      onAdd: (e) => _addEvent(e),
                    ),
                  ],
                ),
              ),

              // day’s events list
              _EventPane(
                day: selected,
                events: _eventsFor(selected),
                onToggle: (id, original, checked) {

                },
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
/// DAY CELL
/// ---------------------------------------------------------------------------

class _StreakBar extends StatelessWidget {
  const _StreakBar({required this.event, required this.day});

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
      decoration: const BoxDecoration(
        color: Color(0xFFFFF5D6),
      ),
      alignment: Alignment.topLeft,
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

    final dayEvents =
    events.where((e) => !(e.allDay && e.end != null)).toList();

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
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: numberColor,
                      ),
                    ),
                  ),
                ),
              ),

              if (streak != null)
                SizedBox(
                  height: streakHeight,
                  child: _StreakBar(event: streak, day: day),
                ),

              // EVENTS
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

                      final rows =
                      hasOverflow ? maxVisibleRows : eventsToShow;

                      if (rows == 0) {
                        return const SizedBox.shrink();
                      }

                      final rowH = max(
                        0.0,
                        (available - rowGap * max(0, rows - 1)) / rows,
                      ) *
                          0.98;

                      final children = <Widget>[];

                      if (!hasOverflow) {
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(
                            _EventRow(
                              e: dayEvents[i],
                              height: rowH,
                              indicatorColor:
                              _indicatorColors[i % _indicatorColors.length],
                            ),
                          );
                          if (i != eventsToShow - 1) {
                            children.add(const SizedBox(height: rowGap));
                          }
                        }
                      } else {
                        for (int i = 0; i < eventsToShow; i++) {
                          children.add(
                            _EventRow(
                              e: dayEvents[i],
                              height: rowH,
                              indicatorColor:
                              _indicatorColors[i % _indicatorColors.length],
                            ),
                          );
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
  const _EventRow({required this.e, required this.height, this.indicatorColor});

  final CalendarEvent e;
  final double height;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final fs = min(12.0, max(9.0, height * 0.9));
    final barHeight = fs;

    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: barHeight,
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
    final allDaySingles =
    events.where((e) => e.allDay && e.end == null).toList();
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
  const _BaseEventCard({
    required this.child,
    this.marginTop = 8,
    this.height,
    this.verticalPadding = 10,
  });

  final Widget child;
  final double marginTop;
  final double? height;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.fromLTRB(12, marginTop, 12, 0),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(9),
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
      child: Row(
        children: [
          const _LabelWithBar(
            barColor: Color(0xFFFFC542),
            text: 'Streak',
            textColor: Color(0xFFDA9A00),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 18, color: const Color(0xFFE0E0E0)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatScreen(event: event),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
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
              children: const [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.black45,
                ),
                Positioned(right: -6, top: -6, child: _Badge(number: 2)),
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
      height: 38,
      verticalPadding: 8,
      child: Row(
        children: [
          _LabelWithBar(
            barColor: const Color(0xFF3AA1FF),
            text: 'All day',
            textColor: const Color(0xFF3AA1FF),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 18, color: const Color(0xFFE0E0E0)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.autorenew_rounded,
              size: 18,
              color: Colors.black26,
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AllDayScreen()));
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
    final hasChecklist = event.checklist.isNotEmpty;

    return _BaseEventCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 70,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fmt(event.start),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        height: 1.0,
                      ),
                    ),
                    if (event.end != null)
                      Text(
                        _fmt(event.end!),
                        style: TextStyle(
                          color: Colors.black.withOpacity(.45),
                          fontSize: 11,
                          height: 1.0,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 1,
                      height: 18,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          ChatScreen(event: event),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // start off-screen right
                        const end = Offset.zero;        // end at normal position
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
                        if (hasChecklist)
                          const Positioned(
                            right: -6,
                            top: -6,
                            child: _Badge(number: 2),
                          ),
                      ],
                    ),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          CupertinoIcons.list_bullet,
                          size: 18,
                          color: Colors.black45,
                        ),
                        Positioned(
                          // adjust these to match your design
                          right: -6,
                          top: -12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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
          if (hasChecklist) ...[
            const SizedBox(height: 10),
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
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
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
  const _GhostPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
          PageRouteBuilder<CalendarEvent>(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EventEditorScreen(initialDate: initialDate),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // from right
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
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
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateRangeBottomSheet(
        initialStart: _startDate,
        initialEnd: _multiDay ? _endDate : null,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = _dOnly(result.start);
        _endDate = _dOnly(result.end);
        _multiDay = !_startDate.isAtSameMomentAs(_endDate);
      });
    }
  }

  Future<void> _openTimeRangePicker() async {
    final result = await showModalBottomSheet<TimeRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TimeRangeBottomSheet(
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
        location:
        _location.text.trim().isEmpty ? null : _location.text.trim(),
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
            icon: const Icon(Icons.check_rounded, color: Color(0xFF3AC3FF)),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

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
            _EditorRow(
              icon: Icons.access_time_rounded,
              label: DateFormat('hh : mm a')
                  .format(_combine(_startDate, _startTime)),
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
            _EditorRow(
              icon: Icons.place_outlined,
              label: 'Location',
              labelColor: labelColor,
              expandMiddle: true,
              middleChild: TextField(
                controller: _location,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Location',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
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
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: labelColor,
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
            if (trailing != null) ...[const Spacer(), trailing!],
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
          border: Border.all(color: const Color(0xFFE1E3EC)),
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
    const hintColor = Color(0xFFDBDBDB);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todos.isNotEmpty) ...[
            for (int i = 0; i < todos.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      todos[i].replaceFirst(RegExp(r'^\[( |x)\]\s?'), ''),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemove(i),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: newTodoController,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmit,
            maxLines: 2,
            minLines: 1,
            decoration: const InputDecoration(
              isCollapsed: true,
              hintText: 'New todo',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 12,
                color: hintColor,
              ),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'New notes',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 12,
                color: hintColor,
              ),
            ),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
