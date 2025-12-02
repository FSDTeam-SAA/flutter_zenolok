import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../home/presentation/screens/home.dart';
import '../../../home/presentation/screens/notification_screen.dart';
import '../../../home/presentation/screens/searchScreen.dart';
import '../../../home/presentation/screens/setting_screen.dart';
import '../../../home/presentation/widgets/category_filter_bar.dart';

/// ───────────────────────── MODEL ─────────────────────────────────────────────

class CategoryDesign {
  final Color? color;
  final IconData icon;
  final String name;

  const CategoryDesign({this.color, required this.icon, required this.name});
}

enum EventsTab { upcoming, past, all }

class Event {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String category;
  final Color color;
  final String? location;
  final int badgeCount;
  final bool allDay;
  final bool showParticipantsRow;

  const Event({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    required this.category,
    required this.color,
    this.location,
    this.badgeCount = 0,
    this.allDay = false,
    this.showParticipantsRow = false,
  });
}

/// ───────────────────────── HELPERS ───────────────────────────────────────────

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const _months = [
  'JAN','FEB','MAR','APR','MAY','JUN',
  'JUL','AUG','SEP','OCT','NOV','DEC',
];

String _fmt12(DateTime t) {
  var h = t.hour % 12;
  if (h == 0) h = 12;
  final m = t.minute.toString().padLeft(2, '0');
  final ampm = t.hour >= 12 ? 'PM' : 'AM';
  return '${h.toString().padLeft(2, '0')} : $m $ampm';
}

String _formatDateRange(DateTime start, DateTime? end) {
  final a =
      '${start.day.toString().padLeft(2, '0')} ${_months[start.month - 1]} ${start.year}';
  if (end == null || _sameDay(start, end)) return a;
  final b =
      '${end.day.toString().padLeft(2, '0')} ${_months[end.month - 1]} ${end.year}';
  return '$a  -  $b';
}

String _formatTimeRange(DateTime start, DateTime? end, bool allDay) {
  if (allDay) return 'All day';
  if (end == null) return _fmt12(start);
  return '${_fmt12(start)}  -  ${_fmt12(end)}';
}

String _timelineLabelForAnchor(DateTime d, DateTime anchor) {
  final a = DateTime(anchor.year, anchor.month, anchor.day);
  final b = DateTime(d.year, d.month, d.day);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'Now';
  return diff > 0
      ? '$diff day${diff == 1 ? '' : 's'}'
      : '${-diff} day${diff == -1 ? '' : 's'} ago';
}

/// ───────────────────────── SCREEN ────────────────────────────────────────────

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  static const _horizontalPadding = 24.0;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventsTab _selectedTab = EventsTab.upcoming;

  final List<CategoryDesign> _categories = const [
    CategoryDesign(color: Color(0xFF1D9BF0), icon: Icons.home_rounded, name: 'Home'),
    CategoryDesign(color: Color(0xFFF6B700), icon: Icons.work_rounded, name: 'Work'),
    CategoryDesign(color: Color(0xFFB277FF), icon: Icons.school_rounded, name: 'School'),
    CategoryDesign(color: Color(0xFF22C55E), icon: Icons.person_rounded, name: 'Personal'),
    CategoryDesign(color: Color(0xFFFF3366), icon: Icons.sports_soccer_rounded, name: 'Sport'),
  ];

  // make reassignable; don't mutate shared Set instances
  Set<EventCategory> _filters = {
    EventCategory.home,
    EventCategory.work,
    EventCategory.school,
    EventCategory.personal,
  };

  final DateTime _upcomingAnchor = DateTime(2026, 6, 17);

  // sample data
  late final List<Event> _upcoming = [
    Event(
      id: 'u1',
      title: 'Body check',
      start: DateTime(2026, 6, 17, 8),
      end: DateTime(2026, 6, 17, 9),
      category: 'Personal',
      color: const Color(0xFF34C759),
      location: '20, Farm Road',
      badgeCount: 2,
    ),
    Event(
      id: 'u2',
      title: 'Exhibition week',
      start: DateTime(2026, 6, 18, 8),
      end: DateTime(2026, 6, 21, 9),
      category: 'Work',
      color: const Color(0xFFFFCC00),
      location: 'Asia Expo',
      badgeCount: 2,
    ),
    Event(
      id: 'u3',
      title: 'Family dinner',
      start: DateTime(2026, 6, 21),
      category: 'Home',
      color: const Color(0xFF32ADE6),
      location: 'Home',
      allDay: true,
      badgeCount: 2,
    ),
  ];

  late final DateTime _today =
  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  late final List<Event> _past = [
    Event(
      id: 'p1',
      title: 'Project kickoff',
      start: _today.subtract(const Duration(days: 1, hours: 2)),
      end: _today.subtract(const Duration(days: 1, hours: 1)),
      category: 'Work',
      color: const Color(0xFF9CA3AF),
      location: 'HQ – Room 3',
      badgeCount: 1,
    ),
  ];

  late final List<Event> _all = [..._upcoming, ..._past];

  List<Event> get _tabSorted {
    switch (_selectedTab) {
      case EventsTab.upcoming:
        return [..._upcoming]..sort((a, b) => a.start.compareTo(b.start));
      case EventsTab.past:
        return [..._past]..sort((a, b) => b.start.compareTo(a.start));
      case EventsTab.all:
        return [..._all]..sort((a, b) => a.start.compareTo(b.start));
    }
  }

  bool _isOn(String cat) {
    if (_filters.isEmpty) return true;
    switch (cat) {
      case 'Home': return _filters.contains(EventCategory.home);
      case 'Work': return _filters.contains(EventCategory.work);
      case 'School': return _filters.contains(EventCategory.school);
      case 'Personal': return _filters.contains(EventCategory.personal);
      case 'Sport':
        try {
          return _filters.contains(
            EventCategory.values.firstWhere((e) => e.toString().endsWith('sport')),
          );
        } catch (_) { return true; }
      default: return true;
    }
  }

  List<Event> get _filtered =>
      _filters.isEmpty ? _tabSorted : _tabSorted.where((e) => _isOn(e.category)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP BAR ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                EventsScreen._horizontalPadding, 16, EventsScreen._horizontalPadding, 0,
              ),
              child: Row(
                children: [
                  const _MaybeBackButton(),                // ← back arrow if canPop()
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Events',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => const MinimalSearchScreen(),
                          transitionsBuilder: (_, a, __, child) {
                            final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeInOut));
                            return SlideTransition(position: a.drive(tween), child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.search, color: Colors.black),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, a, __) => const NotificationScreen(),
                              transitionsBuilder: (_, a, __, child) {
                                final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
                                    .chain(CurveTween(curve: Curves.easeInOut));
                                return SlideTransition(position: a.drive(tween), child: child);
                              },
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.bell, color: Colors.black45),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5757), shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => const SettingsScreen(),
                          transitionsBuilder: (_, a, __, child) {
                            final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeInOut));
                            return SlideTransition(position: a.drive(tween), child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // FILTER BAR (pills)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: EventsScreen._horizontalPadding,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    child: CategoryFilterBar(
                      active: _filters,
                      onChange: (newSet) => setState(() {
                        _filters = Set<EventCategory>.from(newSet); // replace, don’t mutate
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // TABS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EventsScreen._horizontalPadding,
              ),
              child: Row(
                children: [
                  _TabLabel(
                    text: 'Upcoming',
                    selected: _selectedTab == EventsTab.upcoming,
                    onTap: () => setState(() => _selectedTab = EventsTab.upcoming),
                  ),
                  const Spacer(),
                  _TabLabel(
                    text: 'Past',
                    selected: _selectedTab == EventsTab.past,
                    onTap: () => setState(() => _selectedTab = EventsTab.past),
                  ),
                  const Spacer(),
                  _TabLabel(
                    text: 'All',
                    selected: _selectedTab == EventsTab.all,
                    onTap: () => setState(() => _selectedTab = EventsTab.all),
                  ),
                  const Spacer(),
                  const _CircleIcon(icon: Icons.sort_rounded, size: 32),
                ],
              ),
            ),

            // LIST (cards)
            Expanded(
              child: _selectedTab == EventsTab.upcoming
                  ? UpcomingRedPanel(
                events: _filtered,
                anchorDate: _upcomingAnchor,
                onEventTap: (e) {},
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EventsScreen._horizontalPadding,
                ),
                child: EventsListSection(
                  events: _filtered,
                  timelineAnchor: null,
                  onEventTap: (e) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ───────────────────────── helpers (icons / chips / tabs) ───────────────────

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _CircleIcon({required this.icon, this.size = 36, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(color: Color(0xFFF9FAFB), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = filled ? color : Colors.white;
    final borderColor = filled ? color : color.withOpacity(0.35);
    final contentColor = filled ? Colors.white : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: contentColor),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: contentColor)),
        ]),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TabLabel({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF444444) : const Color(0xFFC4C4C4);
    return InkWell(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text,
            style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color)),
        const SizedBox(height: 4),
        if (selected)
          Container(
            width: 22, height: 3,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(999)),
          ),
      ]),
    );
  }
}

/// ───────────────────────── EVENTS LIST / TIMELINE (for Past/All) ────────────

class EventsListSection extends StatelessWidget {
  final List<Event> events;
  final DateTime? timelineAnchor;
  final void Function(Event e)? onEventTap;

  const EventsListSection({
    super.key,
    required this.events,
    this.timelineAnchor,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events', style: TextStyle(color: Color(0xFFB0B0B0))),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = events[i];
        final label = timelineAnchor == null ? '' : _timelineLabelForAnchor(e.start, timelineAnchor!);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onEventTap?.call(e),
                child: _EventCard(
                  color: e.color,
                  title: e.title,
                  date: _formatDateRange(e.start, e.end),
                  time: _formatTimeRange(e.start, e.end, e.allDay),
                  location: e.location ?? '',
                  badgeCount: e.badgeCount,
                  showParticipantsRow: e.showParticipantsRow,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final Color color;
  final String title;
  final String date;
  final String time;
  final String location;
  final int badgeCount;
  final bool showParticipantsRow;

  const _EventCard({
    super.key,
    required this.color,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.badgeCount,
    required this.showParticipantsRow,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF8F8F8);
    const textMain = Color(0xFF5C5C5C);
    const textSub = Color(0xFFBDBDBD);
    const kIconMute = Color(0xFFCBCBCB);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textMain)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.location_on_outlined, size: 14, color: textSub),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(location, style: const TextStyle(fontSize: 11, color: textSub), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 6),
                  _IconWithBadge(icon: Icons.chat_bubble_outline_rounded, count: badgeCount > 0 ? 2 : 0),
                  const SizedBox(width: 8),
                  _IconWithBadge(icon: Icons.notifications_none_rounded, count: badgeCount),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz, size: 18, color: kIconMute),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: textSub),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(fontSize: 12, color: textSub)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: textSub),
                  const SizedBox(width: 6),
                  Text(time, style: const TextStyle(fontSize: 12, color: textSub)),
                ]),
                if (showParticipantsRow) ...[
                  const SizedBox(height: 8),
                  Row(children: const [
                    _ParticipantCircle(), SizedBox(width: 4),
                    _ParticipantCircle(), SizedBox(width: 4),
                    _ParticipantCircle(), SizedBox(width: 4),
                    _ParticipantCircle(), Spacer(),
                    Icon(Icons.notifications_none_rounded, size: 16, color: kIconMute),
                  ]),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconWithBadge({required this.icon, required this.count, super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFCBCBCB)),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              alignment: Alignment.center,
              child: Text('$count',
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700, height: 1)),
            ),
          ),
      ],
    );
  }
}

class _ParticipantCircle extends StatelessWidget {
  const _ParticipantCircle({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
    );
  }
}

/// Renders only the "red portion" from the screenshot (Upcoming list)
class UpcomingRedPanel extends StatelessWidget {
  final List<Event> events;
  final DateTime anchorDate; // e.g. DateTime(2026, 6, 17)
  final EdgeInsetsGeometry horizontalPadding;
  final void Function(Event e)? onEventTap;

  const UpcomingRedPanel({
    super.key,
    required this.events,
    required this.anchorDate,
    this.onEventTap,
    this.horizontalPadding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Center(child: Text('No events', style: TextStyle(color: Color(0xFFB0B0B0)))),
      );
    }

    return Padding(
      padding: horizontalPadding,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final e = events[i];
          final label = _timelineLabelForAnchor(e.start, anchorDate);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onEventTap?.call(e),
                  child: _EventCard(
                    color: e.color,
                    title: e.title,
                    date: _formatDateRange(e.start, e.end),
                    time: _formatTimeRange(e.start, e.end, e.allDay),
                    location: e.location ?? '',
                    badgeCount: e.badgeCount,
                    showParticipantsRow: e.showParticipantsRow,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Back button that appears only when there is a previous route to pop.
class _MaybeBackButton extends StatelessWidget {
  const _MaybeBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    if (!canPop) return const SizedBox(width: 40); // keep layout aligned
    return IconButton(
      icon: const Icon(CupertinoIcons.back, color: Colors.black),
      onPressed: () => Navigator.maybePop(context),
      tooltip: 'Back',
    );
  }
}
