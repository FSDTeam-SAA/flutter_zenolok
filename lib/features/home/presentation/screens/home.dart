import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(const CalendarApp());

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3AA1FF),
      brightness: Brightness.light,
    ).copyWith(
      surface: Colors.white,
      background: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exact Calendar',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white, // version-safe white dialogs
        cardColor: Colors.white,
        canvasColor: Colors.white,
      ),
      home: const CalendarHomePage(),
    );
  }
}

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
  // very light backgrounds for pills
  Color get pastel => switch (this) {
    EventCategory.home => const Color(0xFFEAF3FF),   // light blue
    EventCategory.work => const Color(0xFFFFF5D6),   // light yellow
    EventCategory.school => const Color(0xFFF3E9FF), // light purple
    EventCategory.personal => const Color(0xFFE9F7EF), // light green
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
/// PAGE (white bg + black text + scalable + no overflow)
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
    final now = DateTime.now();
    final y = now.year, m = now.month;
    DateTime d(int dd) => DateTime(y, m, dd);

    final sample = <CalendarEvent>[
      CalendarEvent(
        id: 'exhibit',
        title: 'Exhibition week',
        start: d(17),
        end: d(21),
        allDay: true,
        category: EventCategory.work,
      ),
      CalendarEvent(
        id: 'family',
        title: 'Family dinner',
        start: d(17),
        allDay: true,
        category: EventCategory.home,
      ),
      CalendarEvent(
        id: 'body',
        title: 'Body check',
        start: DateTime(y, m, 17, 8, 0),
        end: DateTime(y, m, 17, 9, 0),
        category: EventCategory.personal,
        location: '20, Farm Road',
        checklist: const ['[ ] Medic card', '[ ] ID card', '[x] Insurance Form'],
      ),
      CalendarEvent(
        id: 'tennis',
        title: 'Tennis practice',
        start: DateTime(y, m, 24, 18, 30),
        end: DateTime(y, m, 24, 20, 0),
        category: EventCategory.personal,
      ),
      CalendarEvent(
        id: 'meeting',
        title: 'Meeting',
        start: DateTime(y, m, 25, 10, 0),
        end: DateTime(y, m, 25, 11, 0),
        category: EventCategory.work,
      ),
      CalendarEvent(
        id: 'school',
        title: 'School fair',
        start: d(26),
        allDay: true,
        category: EventCategory.school,
      ),
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
      TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(.35));

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? _dOnly(DateTime.now());

    // scalable sizes
    final rowHeight = (60.0 * _scale).clamp(52.0, 96.0);
    final dowHeight = (24.0 * _scale).clamp(18.0, 36.0);

    // derived metrics
    final pillTop = rowHeight * 0.60; // where the little pills begin
    final streakInset = rowHeight * 0.35; // yellow band thickness/offset
    final dateDia = rowHeight * 0.58; // ring size
    final cellVMargin = rowHeight * 0.10;

    final calHeight = dowHeight + rowHeight * 6 + 8;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(DateFormat('MMM').format(_focused.value).toUpperCase(), style: _monthBig),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy').format(_focused.value), style: _yearLight),
                  const Spacer(),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.search_rounded, color: Colors.black)),
                  Stack(children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_rounded, color: Colors.black)),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF5757), shape: BoxShape.circle)),
                    ),
                  ]),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_rounded, color: Colors.black)),
                ],
              ),
            ),

            // (Zoom controls removed as requested)

            // Calendar
            GestureDetector(
              onScaleStart: (d) => _baseScale = _scale,
              onScaleUpdate: (d) => setState(() => _scale = (_baseScale * d.scale).clamp(.9, 1.4)),
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
                  onDaySelected: (sel, foc) =>
                      setState(() {
                        _selected = _dOnly(sel);
                        _focused.value = foc;
                      }),
                  rowHeight: rowHeight,
                  daysOfWeekHeight: dowHeight,
                  eventLoader: _eventsFor,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (dt, _) =>
                        DateFormat('E').format(dt).substring(0, 1).toUpperCase(),
                    weekdayStyle: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black.withOpacity(.55)),
                    weekendStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.grey),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle:
                    const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                    weekendTextStyle:
                    const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4C9BFF), width: 1.5),
                    ),
                    selectedDecoration: const BoxDecoration(color: Colors.transparent),
                    selectedTextStyle: const TextStyle(color: Colors.black),
                    cellMargin: EdgeInsets.symmetric(vertical: cellVMargin, horizontal: 2),
                  ),
                  calendarBuilders: CalendarBuilders(
                    // remove default dots
                    markerBuilder: (context, day, events) => const SizedBox.shrink(),
                    defaultBuilder: (context, day, _) => _DayCell(
                      day: day,
                      isToday: _dOnly(day) == _dOnly(DateTime.now()),
                      isSelected: _selected != null && _dOnly(day) == _selected,
                      inStreak: _isStreakDay(day),
                      events: _eventsFor(day),
                      pillTop: pillTop,
                      streakInset: streakInset,
                      dateDiameter: dateDia,
                    ),
                    selectedBuilder: (context, day, _) => _DayCell(
                      day: day,
                      isToday: _dOnly(day) == _dOnly(DateTime.now()),
                      isSelected: true,
                      inStreak: _isStreakDay(day),
                      events: _eventsFor(day),
                      pillTop: pillTop,
                      streakInset: streakInset,
                      dateDiameter: dateDia,
                    ),
                    todayBuilder: (context, day, _) => _DayCell(
                      day: day,
                      isToday: true,
                      isSelected: _selected != null && _dOnly(day) == _selected,
                      inStreak: _isStreakDay(day),
                      events: _eventsFor(day),
                      pillTop: pillTop,
                      streakInset: streakInset,
                      dateDiameter: dateDia,
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

            // Event pane (kept as in your code)
            Expanded(
              child: _EventPane(
                day: selected,
                events: _eventsFor(selected),
                onToggle: (id, original, checked) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// DAY CELL — selected: SMALL rounded-square behind date; "+N" bubble; no overflow.
/// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.inStreak,
    required this.events,
    required this.pillTop,
    required this.streakInset,
    required this.dateDiameter,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool inStreak;
  final List<CalendarEvent> events;
  final double pillTop;
  final double streakInset;
  final double dateDiameter;

  @override
  Widget build(BuildContext context) {
    final isSunday = day.weekday == DateTime.sunday;

    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight;

      // exact sizing used both in capacity calc and rendering
      final pillH = (h * 0.23).clamp(12.0, 18.0);
      final gap = (h * 0.03).clamp(1.0, 3.0);

      // small date tag
      final tagH = (h * 0.28).clamp(18.0, 24.0);
      final tagTop = max(2.0, pillTop - tagH - gap * 1.2);

      // available space below pillTop (subtract epsilon to avoid fractional overflow)
      final available = max(0.0, h - pillTop) - 0.6;

      // capacity formula: n*pillH + (n-1)*gap <= available
      int cap = 0;
      if (available >= pillH) cap = ((available + gap) / (pillH + gap)).floor();
      cap = min(cap, 3); // show at most 3
      final visible = events.take(cap).toList();
      final hidden = max(0, events.length - visible.length);

      final numberColor = (isSunday ? const Color(0xFF9E9E9E) : Colors.black);

      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // thin yellow streak band
          if (inStreak)
            Positioned.fill(
              top: streakInset,
              bottom: streakInset,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E57A),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

          // Date (selected gets a small rounded square; otherwise today ring)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: isSelected ? tagTop : max(2, streakInset / 2)),
              width: isSelected ? null : dateDiameter,
              height: isSelected ? tagH : dateDiameter,
              padding: isSelected ? const EdgeInsets.symmetric(horizontal: 8) : null,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                color: const Color(0xFFE6EAF0),
                borderRadius: BorderRadius.circular(6),
              )
                  : (isToday
                  ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4C9BFF), width: 1.5),
              )
                  : null),
              child: Text(
                '${day.day}',
                style: TextStyle(fontWeight: FontWeight.w800, color: numberColor),
              ),
            ),
          ),

          // Pills (capacity-controlled; after 3 -> always shows +N)
          Positioned(
            top: pillTop,
            left: 2,
            right: 2,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < visible.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : gap),
                    child: _MiniPill(
                      e: visible[i],
                      height: pillH,
                      // background differs per category (soft pastel)
                      background: visible[i].category.pastel,
                    ),
                  ),
              ],
            ),
          ),

          // Always show "+N" when more than 3 events exist
          if (hidden > 0)
            Positioned(
              right: 4,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Text(
                  '+$hidden',
                  style: TextStyle(
                    fontSize: max(9.0, h * 0.12),
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(.75),
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Mini pill with colored background per event
class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.e,
    required this.height,
    required this.background,
  });

  final CalendarEvent e;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final baseSize = max(11.0, height * 0.72);
    return SizedBox(
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black.withOpacity(.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 1,
              spreadRadius: .1,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: height - 4,
              decoration: BoxDecoration(
                color: e.category.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Tooltip(
                message: e.title,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e.title,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: baseSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// EVENT PANE (unchanged behavior)
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

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        if (streaks.isNotEmpty) ...[
          _SectionHeader(label: 'Streak'),
          ...streaks.map((e) => _RowCard(
            child: Row(
              children: [
                const _Tag(color: Color(0xFFFFD84D), text: 'Streak'),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e.title,
                        style: const TextStyle(fontWeight: FontWeight.w800))),
              ],
            ),
          )),
        ],
        if (allDaySingles.isNotEmpty) ...[
          _SectionHeader(label: 'All day'),
          ...allDaySingles.map((e) => _RowCard(
            child: Row(
              children: [
                const _Tag(
                    color: Color(0xFFEAF3FF),
                    text: 'All day',
                    textColor: Color(0xFF3AA1FF)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e.title,
                        style: const TextStyle(fontWeight: FontWeight.w800))),
                const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
              ],
            ),
          )),
        ],
        ...timed.map((e) => _TimedCard(
          event: e,
          onToggle: (item, v) => onToggle(e.id, item, v),
        )),
        if (streaks.isEmpty && allDaySingles.isEmpty && timed.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: Text('No events yet. Tap “+” to add.',
                    style: TextStyle(color: Colors.black))),
          ),
      ],
    );
  }
}

class _TimedCard extends StatelessWidget {
  const _TimedCard({required this.event, required this.onToggle});
  final CalendarEvent event;
  final void Function(String item, bool checked) onToggle;

  String _fmt(DateTime t) => DateFormat('h:mm a').format(t);

  @override
  Widget build(BuildContext context) {
    return _RowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmt(event.start),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  if (event.end != null)
                    Text(_fmt(event.end!),
                        style: TextStyle(color: Colors.black.withOpacity(.45))),
                ],
              ),
            ),
            Expanded(
              child: Row(children: [
                Expanded(
                  child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    if (event.location != null)
                      Text(event.location!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.black.withOpacity(.55))),
                  ]),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more_rounded,
                    size: 18, color: Colors.black38),
              ]),
            ),
          ]),
          if (event.checklist.isNotEmpty) const SizedBox(height: 8),
          ...event.checklist.map((raw) {
            final checked = raw.startsWith('[x]');
            final label = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '');
            return InkWell(
              onTap: () => onToggle(raw, !checked),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      checked
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color:
                      checked ? const Color(0xFF18A957) : Colors.black26,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(label)),
                  ],
                ),
              ),
            );
          }),
          if (event.checklist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('New todo',
                  style: TextStyle(color: Colors.black.withOpacity(.3))),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(label,
          style: TextStyle(
              color: Colors.black.withOpacity(.6),
              fontWeight: FontWeight.w900)),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.color, required this.text, this.textColor});
  final Color color;
  final String text;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor ?? Colors.black87)),
    );
  }
}

class _GhostPill extends StatelessWidget {
  const _GhostPill(
      {required this.icon, required this.label, required this.onTap});
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
            borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.black)),
        ]),
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
        final created = await showDialog<CalendarEvent>(
          context: context,
          builder: (_) => AddEventDialog(initialDate: initialDate),
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
                offset: const Offset(0, 2))
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ADD EVENT DIALOG — (kept from your code)
/// ---------------------------------------------------------------------------

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key, required this.initialDate});
  final DateTime initialDate;

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  EventCategory _category = EventCategory.home;

  DateTime _startDate = _dOnly(DateTime.now());
  DateTime _endDate = _dOnly(DateTime.now());
  bool _allDay = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: Colors.black);

    return AlertDialog(
      title: const Text('Add event', style: TextStyle(color: Colors.black)),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _title,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon:
                  const Icon(Icons.event_rounded, size: 18, color: Colors.black),
                  label: Text(DateFormat('EEE, MMM d').format(_startDate),
                      style: labelStyle),
                  onPressed: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2035),
                      builder: (c, child) => Theme(
                        data: Theme.of(c!).copyWith(
                          colorScheme:
                          Theme.of(c).colorScheme.copyWith(surface: Colors.white),
                        ),
                        child: child!,
                      ),
                    );
                    if (p != null) {
                      setState(() {
                        _startDate = _dOnly(p);
                        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<EventCategory>(
                  value: _category,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(),
                  ),
                  items: EventCategory.values
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(children: [
                      Icon(c.icon, size: 18, color: c.color),
                      const SizedBox(width: 8),
                      Text(c.label,
                          style: const TextStyle(color: Colors.black)),
                    ]),
                  ))
                      .toList(),
                  onChanged: (c) => setState(() => _category = c!),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SwitchListTile(
              title:
              const Text('All day', style: TextStyle(color: Colors.black)),
              value: _allDay,
              onChanged: (v) =>
                  setState(() {
                    _allDay = v;
                    if (!v) _multiDay = false;
                  }),
              contentPadding: EdgeInsets.zero,
            ),
            if (_allDay)
              SwitchListTile(
                title: const Text('Multi-day (streak)',
                    style: TextStyle(color: Colors.black)),
                value: _multiDay,
                onChanged: (v) => setState(() => _multiDay = v),
                contentPadding: EdgeInsets.zero,
              ),
            if (!_allDay)
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule_rounded,
                        size: 18, color: Colors.black),
                    label:
                    Text(_startTime.format(context), style: labelStyle),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule_rounded,
                        size: 18, color: Colors.black),
                    label: Text(_endTime.format(context), style: labelStyle),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _endTime);
                      if (t != null) setState(() => _endTime = t);
                    },
                  ),
                ),
              ]),
            if (_allDay && _multiDay)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month_rounded,
                      size: 18, color: Colors.black),
                  label: Text('End: ${DateFormat('EEE, MMM d').format(_endDate)}',
                      style: labelStyle),
                  onPressed: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime(2035),
                      builder: (c, child) => Theme(
                        data: Theme.of(c!).copyWith(
                          colorScheme:
                          Theme.of(c).colorScheme.copyWith(surface: Colors.white),
                        ),
                        child: child!,
                      ),
                    );
                    if (p != null) setState(() => _endDate = _dOnly(p));
                  },
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black))),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            final start =
            _allDay ? _startDate : _combine(_startDate, _startTime);
            final DateTime? end = _allDay
                ? (_multiDay ? _endDate : null)
                : _combine(_startDate, _endTime);
            Navigator.pop(
              context,
              CalendarEvent(
                id: UniqueKey().toString(),
                title: _title.text.trim(),
                start: start,
                end: end,
                allDay: _allDay,
                location: _location.text.trim().isEmpty
                    ? null
                    : _location.text.trim(),
                category: _category,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
