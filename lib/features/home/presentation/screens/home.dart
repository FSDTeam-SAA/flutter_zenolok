import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/searchScreen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/calendar_event.dart';
import '../controller/brick_controller.dart';
import '../controller/event_controller.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/cateogry_widget.dart';
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

DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _betweenIncl(DateTime x, DateTime a, DateTime b) {
  final dx = _dOnly(x), da = _dOnly(a), db = _dOnly(b);
  return (dx.isAtSameMomentAs(da) || dx.isAfter(da)) &&
      (dx.isAtSameMomentAs(db) || dx.isBefore(db));
}

/// ✅ NEW: distinguish multi-day all-day (true streak) vs single-day all-day
bool _isMultiDayAllDay(CalendarEvent e) {
  if (!e.allDay || e.end == null) return false;
  final s = _dOnly(e.start);
  final en = _dOnly(e.end!);
  return !s.isAtSameMomentAs(en);
}

/// "#RRGGBB" or "#AARRGGBB" -> Color
Color _hexToColor(String hex, {Color fallback = const Color(0xFF3AA1FF)}) {
  final raw = hex.replaceAll('#', '').trim();
  try {
    if (raw.length == 6) return Color(int.parse('FF$raw', radix: 16));
    if (raw.length == 8) return Color(int.parse(raw, radix: 16));
  } catch (_) {}
  return fallback;
}

BrickModel? _brickById(List<BrickModel> bricks, String id) {
  for (final b in bricks) {
    if (b.id == id) return b;
  }
  return null;
}

Color _eventColor(List<BrickModel> bricks, CalendarEvent e) {
  final b = _brickById(bricks, e.categoryId);
  if (b == null) return const Color(0xFF3AA1FF);
  return _hexToColor(b.color, fallback: const Color(0xFF3AA1FF));
}

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

  /// ✅ brickIds filter (empty = show all)
  final Set<String> _filters = {};

  @override
  void initState() {
    super.initState();

    Get.find<BrickController>().loadBricks();
    Get.find<EventController>().loadMonth(_focused.value);
  }

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  /// ✅ Get ALL events currently cached in EventController (month store)
  Iterable<CalendarEvent> _allEventsFromController() {
    final dynamic ec = Get.find<EventController>();

    try {
      final Iterable<CalendarEvent> all = ec.allEvents();
      return all;
    } catch (_) {}

    try {
      final dynamic store = ec.store;
      final Iterable<CalendarEvent> all = (store.values as Iterable).expand(
        (v) => (v as List).cast<CalendarEvent>(),
      );
      return all;
    } catch (_) {}

    return const <CalendarEvent>[];
  }

  List<CalendarEvent> _eventsFor(DateTime day) {
    final k = _dOnly(day);

    // exact events from controller for that day
    final List<CalendarEvent> exact = Get.find<EventController>().eventsForDay(
      k,
    );

    // ✅ ONLY multi-day all-day streaks should span across dates
    final spanning = _allEventsFromController().where(
      (e) => _isMultiDayAllDay(e) && _betweenIncl(day, e.start, e.end!),
    );

    final merged = <CalendarEvent>[];
    merged.addAll(exact);

    for (final e in spanning) {
      if (!merged.contains(e)) merged.add(e);
    }

    if (_filters.isEmpty) return merged;
    return merged.where((e) => _filters.contains(e.categoryId)).toList();
  }

  bool _isStreakDay(DateTime day) {
    return _allEventsFromController().any(
      (e) => _isMultiDayAllDay(e) && _betweenIncl(day, e.start, e.end!),
    );
  }

  // Future<void> _addEvent(CalendarEvent e) async {
  //   await Get.find<EventController>().createEventFromUi(e);
  //   // await Get.find<EventController>().loadMonth(_focused.value);
  //
  //   setState(() {
  //     _selected = _dOnly(e.start);
  //     _focused.value = _dOnly(e.start);
  //   });
  // }

  Future<void> _addEvent(CalendarEvent e) async {
    await Get.find<EventController>().createEventFromUi(e);

    setState(() {
      _selected = _dOnly(e.start);
      _focused.value = _dOnly(e.start);
    });

    // ✅ optional: ensure todos are loaded for the selected day
    await Get.find<EventController>().ensureTodosLoadedForDay(_selected!);
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

  Future<void> _openHeaderDatePicker() async {
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          DateRangeBottomSheet(initialStart: _focused.value, initialEnd: null),
    );

    if (result != null) {
      setState(() {
        _focused.value = result.start;
        _selected = _dOnly(result.start);
      });

      Get.find<EventController>().loadMonth(result.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? _dOnly(DateTime.now());

    final rowHeight = (90.0 * _scale).clamp(58.0, 96.0);
    final dowHeight = (50.0 * _scale).clamp(20.0, 36.0);

    final dateAreaHeight = rowHeight * 0.25;
    final dateDia = rowHeight * 0.58;

    final cellGapV = max(8.0, rowHeight * 0.3);

    // ✅ UI FIX (streak yellow line looks continuous like your screenshots)
    final cellGapH = 0.0;

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
                    InkWell(
                      onTap: _openHeaderDatePicker,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat(
                              'MMM',
                            ).format(_focused.value).toUpperCase(),
                            style: _monthBig,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy').format(_focused.value),
                            style: _yearLight,
                          ),
                        ],
                      ),
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
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
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

                    // ✅ loading bar in header
                    Obx(
                      () => Get.find<EventController>().loading.value
                          ? const LinearProgressIndicator(minHeight: 2)
                          : const SizedBox.shrink(),
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
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
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
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
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
                  activeIds: _filters,
                  onChange: (newSet) => setState(() {
                    _filters
                      ..clear()
                      ..addAll(newSet);
                  }),
                  onAddPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoryEditorScreen(),
                      ),
                    );
                    Get.find<BrickController>().loadBricks();
                  },
                ),
              ),

              // Calendar + Event list rebuild on controller update
              GetBuilder<EventController>(
                builder: (_) {
                  return Column(
                    children: [
                      GestureDetector(
                        onScaleStart: (d) => _baseScale = _scale,
                        onScaleUpdate: (d) => setState(
                          () => _scale = (_baseScale * d.scale).clamp(.9, 1.4),
                        ),
                        child: SizedBox(
                          height: calHeight,
                          child: TableCalendar<CalendarEvent>(
                            firstDay: DateTime.utc(2015, 1, 1),
                            lastDay: DateTime.utc(2035, 12, 31),
                            focusedDay: _focused.value,
                            onPageChanged: (d) async {
                              setState(() => _focused.value = d);
                              await Get.find<EventController>().loadMonth(d);

                              if (_selected != null) {
                                await Get.find<EventController>()
                                    .ensureTodosLoadedForDay(_selected!);
                              }
                            },

                            headerVisible: false,
                            calendarFormat: _format,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            selectedDayPredicate: (d) =>
                                _selected != null && _dOnly(d) == _selected,
                            onDaySelected: (sel, foc) async {
                              setState(() {
                                _selected = _dOnly(sel);
                                _focused.value = foc;
                              });

                              // ✅ load todos for events of this day (NO UI change)
                              await Get.find<EventController>()
                                  .ensureTodosLoadedForDay(_selected!);
                            },

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
                                final text = DateFormat(
                                  'E',
                                ).format(day).substring(0, 1).toUpperCase();
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
                                    _selected != null &&
                                    _dOnly(day) == _selected,
                                inStreak: _isStreakDay(day),
                                events: _eventsFor(day),
                                dateAreaHeight: dateAreaHeight,
                                todayRingDiameter: dateDia,
                              ),
                              selectedBuilder: (context, day, _) => _DayCell(
                                day: day,
                                isToday: _dOnly(day) == _dOnly(DateTime.now()),
                                isSelected: true,
                                inStreak: _isStreakDay(day),
                                events: _eventsFor(day),
                                dateAreaHeight: dateAreaHeight,
                                todayRingDiameter: dateDia,
                              ),
                              todayBuilder: (context, day, _) => _DayCell(
                                day: day,
                                isToday: true,
                                isSelected:
                                    _selected != null &&
                                    _dOnly(day) == _selected,
                                inStreak: _isStreakDay(day),
                                events: _eventsFor(day),
                                dateAreaHeight: dateAreaHeight,
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
                            _FlatPlusButton(
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
                        onToggle: (id, original, checked) {},
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    final controller = Get.find<BrickController>();
    final color = _eventColor(controller.bricks, event);

    final d = _dOnly(day);
    final s = _dOnly(event.start);
    final e = _dOnly(event.end!);

    // ✅ UI: yellow line with rounded ends (like screenshots)
    final isStart = d.isAtSameMomentAs(s);
    final isEnd = d.isAtSameMomentAs(e);

    // ✅ UI: show title only at start day (no repeating)
    final showLabel = isStart;

    final radius = BorderRadius.horizontal(
      left: isStart ? const Radius.circular(10) : Radius.zero,
      right: isEnd ? const Radius.circular(10) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFFF5D6)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      alignment: Alignment.centerLeft,
      child: showLabel
          ? Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
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

    final streaks = events.where(_isMultiDayAllDay).toList();
    final CalendarEvent? streak = streaks.isNotEmpty ? streaks.first : null;

    // ✅ keep ALL non-streak events visible in cell (includes single-day allDay)
    final dayEvents = events.where((e) => !_isMultiDayAllDay(e)).toList();

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

                            final rows = hasOverflow
                                ? maxVisibleRows
                                : eventsToShow;

                            if (rows == 0) return const SizedBox.shrink();

                            final rowH =
                                max(
                                  0.0,
                                  (available - rowGap * max(0, rows - 1)) /
                                      rows,
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
                                        _indicatorColors[i %
                                            _indicatorColors.length],
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
                                        _indicatorColors[i %
                                            _indicatorColors.length],
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
              color: indicatorColor ?? const Color(0xFF3AA1FF),
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
    final streaks = events.where(_isMultiDayAllDay).toList();

    // ✅ single-day allDay will appear here (even if API returns endTime not null)
    final allDaySingles = events
        .where((e) => e.allDay && !_isMultiDayAllDay(e))
        .toList();

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

// ---------------- UI Cards (unchanged) ----------------

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

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

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

          // ✅ NO UI CHANGE: same icon, only behavior fixed
          GestureDetector(
            onTap: () async {
              final edited = await Navigator.of(context).push<CalendarEvent>(
                MaterialPageRoute(
                  builder: (_) => EventEditorScreen(
                    initialDate: event.start,
                    existingEvent: event,
                  ),
                ),
              );

              if (edited == null) return;

              final ec = Get.find<EventController>();

              // ✅ update with original id (important)
              await ec.updateEventFromUi(event.id, edited);

              // ✅ refresh old month (remove from old date)
              await ec.loadMonth(event.start);

              // ✅ refresh new month if user moved event to another month
              if (!_sameMonth(event.start, edited.start)) {
                await ec.loadMonth(edited.start);
              }
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

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

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

          // ✅ NO UI change: keep same icon + size
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.autorenew_rounded,
              size: 18,
              color: Colors.black26,
            ),
            onPressed: () async {
              // ✅ open editor with existing event data
              final edited = await Navigator.of(context).push<CalendarEvent>(
                MaterialPageRoute(
                  builder: (_) => EventEditorScreen(
                    initialDate: event.start,
                    existingEvent: event,
                  ),
                ),
              );

              if (edited == null) return;

              final ec = Get.find<EventController>();

              // ✅ update backend/store using same id
              await ec.updateEventFromUi(event.id, edited);

              // ✅ refresh old month (remove from old date)
              await ec.loadMonth(event.start);

              // ✅ refresh new month if moved to different month
              if (!_sameMonth(event.start, edited.start)) {
                await ec.loadMonth(edited.start);
              }

              // (optional, safe) ensure todos loaded for the new day
              await ec.ensureTodosLoadedForDay(_dOnly(edited.start));
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

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    final hasChecklist = event.checklist.isNotEmpty;

    return _BaseEventCard(
      marginTop: 6,
      verticalPadding: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left color bar (keep UI)
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 3),

              SizedBox(
                width: 56,
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
                      height: 16,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 4),
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
                              fontSize: 13,
                              height: 1.0,
                            ),
                          ),
                          if (event.location != null)
                            Text(
                              event.location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.0,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // ✅ NO UI change: keep same icons/stack/arrow
              GestureDetector(
                onTap: () async {
                  // ✅ open editor with existing event data
                  final edited = await Navigator.of(context).push<CalendarEvent>(
                    MaterialPageRoute(
                      builder: (_) => EventEditorScreen(
                        initialDate: event.start,
                        existingEvent: event,
                      ),
                    ),
                  );

                  if (edited == null) return;

                  final ec = Get.find<EventController>();

                  // ✅ update backend/store using same id
                  await ec.updateEventFromUi(event.id, edited);

                  // ✅ refresh old month (remove from old day/month)
                  await ec.loadMonth(event.start);

                  // ✅ refresh new month if moved to different month
                  if (!_sameMonth(event.start, edited.start)) {
                    await ec.loadMonth(edited.start);
                  }

                  // ✅ ensure todos loaded for the new selected day
                  await ec.ensureTodosLoadedForDay(_dOnly(edited.start));
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
                    const SizedBox(width: 6),
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
            const SizedBox(height: 8),
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
    const borderColor = Color(0xFFB6B5B5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: borderColor),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: borderColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FULL-SCREEN EDITOR + CUSTOM DATE/TIME PICKERS
/// ---------------------------------------------------------------------------

class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({
    super.key,
    required this.initialDate,
    this.existingEvent,
  });

  final DateTime initialDate;
  final CalendarEvent? existingEvent;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _newTodo = TextEditingController();
  final _newNote = TextEditingController();
  final List<String> _todos = [];

  String? _selectedBrickId;
  late Set<String> _editorFilters;

  DateTime _startDate = _dOnly(DateTime.now());
  DateTime _endDate = _dOnly(DateTime.now());

  bool _allDay = true;
  bool _multiDay = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  bool _isSameDay(DateTime a, DateTime b) {
    final da = _dOnly(a);
    final db = _dOnly(b);
    return da.isAtSameMomentAs(db);
  }

  @override
  void initState() {
    super.initState();

    final e = widget.existingEvent;

    // ✅ CREATE MODE (no existing event)
    if (e == null) {
      _startDate = _dOnly(widget.initialDate);
      _endDate = _startDate;

      _editorFilters = <String>{};
      _selectedBrickId = null;
      return;
    }

    // ✅ EDIT MODE: PREFILL EVERYTHING (NO UI CHANGE)
    _title.text = e.title;
    _location.text = e.location ?? '';

    _todos
      ..clear()
      ..addAll(e.checklist);

    _selectedBrickId = e.categoryId;
    _editorFilters = {e.categoryId};

    _allDay = e.allDay;

    if (_allDay) {
      _startDate = _dOnly(e.start);

      // Multi-day all-day only if end exists AND day differs
      if (e.end != null && !_isSameDay(e.start, e.end!)) {
        _multiDay = true;
        _endDate = _dOnly(e.end!);
      } else {
        _multiDay = false;
        _endDate = _startDate;
      }
    } else {
      _multiDay = false;
      _startDate = _dOnly(e.start);
      _endDate = _startDate;

      _startTime = TimeOfDay.fromDateTime(e.start);

      final fallbackEnd = e.start.add(const Duration(hours: 1));
      _endTime = TimeOfDay.fromDateTime(e.end ?? fallbackEnd);

      // safety: end must be after start
      final s = _combine(_startDate, _startTime);
      var en = _combine(_startDate, _endTime);
      if (!en.isAfter(s)) {
        en = s.add(const Duration(hours: 1));
        _endTime = TimeOfDay(hour: en.hour, minute: en.minute);
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _newTodo.dispose();
    _newNote.dispose();
    super.dispose();
  }

  String _dateTextSingleLine() {
    final fmt = DateFormat('EEE, MMM d, yyyy');
    if (_multiDay) {
      return '${fmt.format(_startDate)} — ${fmt.format(_endDate)}';
    }
    return fmt.format(_startDate);
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

        final pickedMulti = !_isSameDay(_startDate, _endDate);

        if (_allDay) {
          _multiDay = pickedMulti;
        } else {
          _multiDay = false;
          _endDate = _startDate;
        }
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

        final s = _combine(_startDate, _startTime);
        var e = _combine(_startDate, _endTime);
        if (!e.isAfter(s)) {
          e = s.add(const Duration(hours: 1));
          _endTime = TimeOfDay(hour: e.hour, minute: e.minute);
        }
      });
    }
  }

  void _setAllDay(bool v) {
    setState(() {
      _allDay = v;

      if (!_allDay) {
        _multiDay = false;
        _endDate = _startDate;

        final s = _combine(_startDate, _startTime);
        var e = _combine(_startDate, _endTime);
        if (!e.isAfter(s)) {
          e = s.add(const Duration(hours: 1));
          _endTime = TimeOfDay(hour: e.hour, minute: e.minute);
        }
      }
    });
  }

  void _save() {
    if (!_form.currentState!.validate()) return;

    if (_selectedBrickId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // ✅ If user typed but didn’t press “done”, still capture it
    final pendingTodo = _newTodo.text.trim();
    if (pendingTodo.isNotEmpty) {
      _todos.add('[ ] $pendingTodo');
      _newTodo.clear();
    }

    final pendingNote = _newNote.text.trim();
    if (pendingNote.isNotEmpty) {
      _todos.add('[ ] $pendingNote');
      _newNote.clear();
    }

    final DateTime start;
    final DateTime? end;

    if (_allDay) {
      start = _startDate;

      end = _multiDay
          ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59)
          : null;
    } else {
      start = _combine(_startDate, _startTime);
      var computedEnd = _combine(_startDate, _endTime);
      if (!computedEnd.isAfter(start)) {
        computedEnd = start.add(const Duration(hours: 1));
      }
      end = computedEnd;
    }

    // ✅ KEEP SAME ID when editing (critical for update)
    final id = widget.existingEvent?.id ?? UniqueKey().toString();

    Navigator.pop(
      context,
      CalendarEvent(
        id: id,
        title: _title.text.trim(),
        start: start,
        end: end,
        allDay: _allDay,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        categoryId: _selectedBrickId!,
        checklist: List<String>.from(_todos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelColor = Color(0xFFB8BBC5);
    const dividerColor = Color(0xFFE5E6EB);

    // ✅ NO UI CHANGES BELOW (same widgets, same layout)
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
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a title'
                        : null,
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
            const SizedBox(height: 16),

            // CATEGORY FILTER BAR (single select)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CategoryFilterBar(
                    activeIds: _editorFilters,
                    onChange: (newSet) {
                      if (newSet.isEmpty) return;

                      String selectedId;
                      if (newSet.length > _editorFilters.length) {
                        selectedId = newSet.firstWhere(
                              (id) => !_editorFilters.contains(id),
                          orElse: () => newSet.last,
                        );
                      } else {
                        selectedId = newSet.first;
                      }

                      setState(() {
                        _selectedBrickId = selectedId;
                        _editorFilters = {selectedId};
                      });
                    },
                    onAddPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoryEditorScreen(),
                        ),
                      );

                      await Get.find<BrickController>().loadBricks();

                      final bricks = Get.find<BrickController>().bricks;
                      if (_selectedBrickId == null && bricks.isNotEmpty) {
                        final lastId = bricks.last.id;
                        setState(() {
                          _selectedBrickId = lastId;
                          _editorFilters = {lastId};
                        });
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // DATE ROW
            _EditorRow(
              icon: Icons.event_outlined,
              label: 'Date',
              labelColor: labelColor,
              expandMiddle: true,
              middleChild: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _dateTextSingleLine(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _CircleIconButton(icon: Icons.notifications_none_rounded),
                  SizedBox(width: 8),
                  _CircleIconButton(icon: Icons.autorenew_rounded),
                ],
              ),
              onTap: _openDateRangePicker,
            ),
            const Divider(color: dividerColor, height: 16),

            // TIME ROW
            _EditorRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              labelColor: Colors.black,
              expandMiddle: true,
              middleChild: _allDay
                  ? Text(
                'All day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(.55),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('hh : mm a')
                            .format(_combine(_startDate, _startTime)),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('hh : mm a')
                            .format(_combine(_startDate, _endTime)),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: _AllDayPill(value: _allDay, onChanged: _setAllDay),
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
              newNoteController: _newNote,
              onRemove: (i) => setState(() => _todos.removeAt(i)),
              onSubmitTodo: (v) {
                final t = v.trim();
                if (t.isEmpty) return;
                setState(() {
                  _todos.add('[ ] $t');
                  _newTodo.clear();
                });
              },
              onSubmitNote: (v) {
                final t = v.trim();
                if (t.isEmpty) return;
                setState(() {
                  _todos.add('[ ] $t');
                  _newNote.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------- Editor widgets + plus button (unchanged) ----------------

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
    final middle =
        middleChild ??
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE1E3EC);
    const iconColor = Color(0xFFC7CAD3);

    final child = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );

    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: child,
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
    required this.newNoteController,
    required this.onRemove,
    required this.onSubmitTodo,
    required this.onSubmitNote,
  });

  final List<String> todos;
  final TextEditingController newTodoController;
  final TextEditingController newNoteController;
  final void Function(int index) onRemove;
  final ValueChanged<String> onSubmitTodo;
  final ValueChanged<String> onSubmitNote;

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

          // New todo (input)
          TextField(
            controller: newTodoController,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitTodo,
            maxLines: 1,
            minLines: 1,
            decoration: const InputDecoration(
              isCollapsed: true,
              hintText: 'New todo',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 12, color: hintColor),
            ),
            style: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 10),

          // New notes (separate controller now ✅)
          TextField(
            controller: newNoteController,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitNote,
            maxLines: 1,
            minLines: 1,
            decoration: const InputDecoration(
              isCollapsed: true,
              hintText: 'New notes',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 12, color: hintColor),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FlatPlusButton extends StatelessWidget {
  const _FlatPlusButton({required this.initialDate, required this.onAdd});

  final DateTime initialDate;
  final void Function(CalendarEvent e) onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final created = await Navigator.of(context).push<CalendarEvent>(
            PageRouteBuilder<CalendarEvent>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EventEditorScreen(initialDate: initialDate),
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

          if (created != null) onAdd(created);
        },
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _PlusPainter(
              color: const Color(0xFFCFCFCF),
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final halfLen = size.shortestSide * 0.35;

    canvas.drawLine(
      Offset(center.dx - halfLen, center.dy),
      Offset(center.dx + halfLen, center.dy),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - halfLen),
      Offset(center.dx, center.dy + halfLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
