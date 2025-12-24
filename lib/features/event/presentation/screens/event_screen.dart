import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../home/data/models/calendar_event.dart';
import '../../../home/presentation/controller/event_controller.dart';
import '../../../home/presentation/screens/notification_screen.dart';
import '../../../home/presentation/screens/searchScreen.dart';
import '../../../home/presentation/screens/setting_screen.dart';
import '../../../home/presentation/widgets/category_filter_bar.dart';

// ✅ IMPORTANT: update these two paths to match your project

/// ───────────────────────── UI MODEL (same as yours) ──────────────────────────
class Event {
  final String title;
  final DateTime start;
  final DateTime? end;
  final String location;
  final Color color;
  final bool allDay;
  final bool showTinyIconsRow;
  final bool hasBadge;

  const Event({
    required this.title,
    required this.start,
    this.end,
    required this.location,
    required this.color,
    this.allDay = false,
    this.showTinyIconsRow = false,
    this.hasBadge = false,
  });
}



/// ───────────────────────── SCREEN ────────────────────────────────────────────
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  TabKind _selected = TabKind.upcoming;

  // ✅ anchor should be NOW for real API data labels
  DateTime get _anchor => DateTime.now();

  final Set<String> _filters = <String>{}; // brick ids

  @override
  void initState() {
    super.initState();

    // initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<EventController>();
      c.refreshEventsUI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<EventController>(
          builder: (controller) {
            // ✅ take list from API (already filtered by tab + brick filters)
            final List<CalendarEvent> apiEvents =
                controller.eventsForSelectedTabFlat;

            // ✅ map CalendarEvent -> UI Event (for your UI)
            final List<Event> uiEvents = apiEvents.map(_mapToUiEvent).toList();

            return Column(
              children: [
                const _TopBar(),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                  child: CategoryFilterBar(
                    activeIds: _filters,
                    onChange: (newSet) {
                      setState(() {
                        _filters
                          ..clear()
                          ..addAll(newSet);
                      });

                      // ✅ send to controller (filters affect list)
                      controller.applyBrickFiltersUI(_filters);
                    },
                  ),
                ),

                const SizedBox(height: 10),

                _TabsRow(
                  selected: _selected,
                  onSelect: (t) async {
                    setState(() => _selected = t);

                    // ✅ tell controller to load tab
                    await controller.changeTabUI(t);
                  },
                ),

                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.3),

                Expanded(
                  child: controller.loading.value
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSection(uiEvents),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ───────────────────────── mapping helper ──────────────────────────────────
  Event _mapToUiEvent(CalendarEvent e) {
    final hex = _getBrickColorHex(e); // ✅ safe
    final color = _hexToColorSafe(hex);

    final hasTodos = e.checklist.isNotEmpty;

    return Event(
      title: e.title,
      start: e.start,
      end: e.end,
      location: _getLocationSafe(e), // ✅ safe
      color: color,
      allDay: e.allDay,
      showTinyIconsRow: hasTodos,
      hasBadge: hasTodos,
    );
  }

  /// ✅ tries: e.brick.color -> e.brickColor -> default
  String _getBrickColorHex(CalendarEvent e) {
    try {
      final dyn = e as dynamic;

      // API shape: e.brick.color
      final brick = dyn.brick;
      if (brick != null) {
        final c = brick.color;
        if (c != null && c.toString().isNotEmpty) return c.toString();
      }
    } catch (_) {}

    try {
      final dyn = e as dynamic;
      final c = dyn.brickColor;
      if (c != null && c.toString().isNotEmpty) return c.toString();
    } catch (_) {}

    return '#9CA3AF';
  }

  /// ✅ tries: e.location -> e.place -> e.address -> empty
  String _getLocationSafe(CalendarEvent e) {
    try {
      final dyn = e as dynamic;
      final v = dyn.location;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final dyn = e as dynamic;
      final v = dyn.place;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final dyn = e as dynamic;
      final v = dyn.address;
      if (v != null) return v.toString();
    } catch (_) {}

    return '';
  }

  Color _hexToColorSafe(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    ) ??
        0xFF9CA3AF;
    return Color(value);
  }




  //----------------------------



  /// Common builder for Upcoming / Past / All (timeline pill + card on SAME ROW)
  Widget _buildSection(List<Event> events) {
    String labelFor(DateTime t) {
      final days = t.difference(_anchor).inDays;
      if (days == 0) return 'Now';
      if (days > 0) return days == 1 ? '1 day' : '$days days';
      final past = days.abs();
      return past == 1 ? '1 day ago' : '$past days ago';
    }

    Widget row(String label, Widget card) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 46, child: _TimelinePill(text: label)),
          const SizedBox(width: 8),
          Expanded(child: card),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          row(labelFor(events[i].start), _eventCardFrom(events[i])),
    );
  }

  Widget _eventCardFrom(Event e) {
    final dateText = _formatDateRange(e.start, e.end);
    final timeText = e.allDay ? 'All day' : _formatTimeRange(e.start, e.end);
    return _EventCard(
      accentColor: e.color,
      title: e.title,
      dateText: dateText,
      timeText: timeText,
      locationText: e.location,
      isAllDay: e.allDay,
      hasBadge: e.hasBadge,
      showTinyIconsRow: e.showTinyIconsRow,
    );
  }

  // formatting helpers
  static const _months = [
    'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
  ];

  String _fmt12(DateTime t) {
    var h = t.hour % 12;
    if (h == 0) h = 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')} : $m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final a =
        '${start.day.toString().padLeft(2, '0')} ${_months[start.month - 1]} ${start.year}';
    if (end == null ||
        (start.year == end.year &&
            start.month == end.month &&
            start.day == end.day)) {
      return a;
    }
    final b =
        '${end.day.toString().padLeft(2, '0')} ${_months[end.month - 1]} ${end.year}';
    return '$a - $b';
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    if (end == null) return _fmt12(start);
    return '${_fmt12(start)} - ${_fmt12(end)}';
  }
}

/// ───────────────────────── UI CHROME (unchanged) ─────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          const Text(
            'Events',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const MinimalSearchScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                      const NotificationScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.bell, color: Colors.black),
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
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

/// Interactive tabs
class _TabsRow extends StatelessWidget {
  final TabKind selected;
  final ValueChanged<TabKind> onSelect;
  const _TabsRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
      child: Row(
        children: [
          _Segment(
            text: 'Upcoming',
            selected: selected == TabKind.upcoming,
            onTap: () => onSelect(TabKind.upcoming),
          ),
          const SizedBox(width: 45),
          _Segment(
            text: 'Past',
            selected: selected == TabKind.past,
            onTap: () => onSelect(TabKind.past),
          ),
          const SizedBox(width: 45),
          _Segment(
            text: 'All',
            selected: selected == TabKind.all,
            onTap: () => onSelect(TabKind.all),
          ),
          const Spacer(),
          const _IconRounded(icon: Icons.tune_rounded),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _Segment({
    required this.text,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const inactiveText = Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : inactiveText,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 3,
              width: selected ? 26 : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconRounded extends StatelessWidget {
  final IconData icon;
  const _IconRounded({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
    );
  }
}

/// ───────────────────────── CARD (your design) ───────────────────────────────
class _EventCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String dateText;
  final String timeText;
  final String locationText;
  final bool isAllDay;
  final bool hasBadge;
  final bool showTinyIconsRow;

  const _EventCard({
    super.key,
    required this.accentColor,
    required this.title,
    required this.dateText,
    required this.timeText,
    required this.locationText,
    this.isAllDay = false,
    this.hasBadge = false,
    this.showTinyIconsRow = false,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7F9);
    const stroke = Color(0xFFE8ECF2);
    const mainText = Color(0xFF0F172A);
    const subText = Color(0xFF6B7280);
    const muteIcon = Color(0xFF9AA3AF);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              height: 20,
              margin: const EdgeInsets.only(left: 10, right: 2, top: 4),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: mainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: muteIcon),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: subText,
                        ),
                      ),
                      const SizedBox(width: 70),
                      const Icon(Icons.place_outlined, size: 16, color: muteIcon),
                      const SizedBox(width: 4),
                      Text(
                        locationText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: subText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: muteIcon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subText,
                          ),
                        ),
                      ),
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showTinyIconsRow) ...const [
                              _CircleIconOutline(icon: Icons.comment),
                              _CircleIconOutline(icon: Icons.refresh),
                              _CircleIconOutline(icon: Icons.notifications_none_rounded),
                            ],
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const _CircleIconOutline(icon: CupertinoIcons.list_bullet),
                                if (hasBadge)
                                  Positioned(
                                    right: -2,
                                    top: -8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _CircleIconOutline extends StatelessWidget {
  final IconData icon;
  const _CircleIconOutline({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: Icon(icon, size: 14, color: const Color(0xFFB0B6C0)),
    );
  }
}

class _TimelinePill extends StatelessWidget {
  final String text;
  const _TimelinePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF9AA3AF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import '../../../home/presentation/screens/home.dart';
// import '../../../home/presentation/screens/notification_screen.dart';
// import '../../../home/presentation/screens/searchScreen.dart';
// import '../../../home/presentation/screens/setting_screen.dart';
// import '../../../home/presentation/widgets/category_filter_bar.dart';
//
// /// ───────────────────────── MODEL ─────────────────────────────────────────────
// class Event {
//   final String title;
//   final DateTime start;
//   final DateTime? end;
//   final String location;
//   final Color color;
//   final bool allDay;
//   final bool showTinyIconsRow;
//   final bool hasBadge;
//
//   const Event({
//     required this.title,
//     required this.start,
//     this.end,
//     required this.location,
//     required this.color,
//     this.allDay = false,
//     this.showTinyIconsRow = false,
//     this.hasBadge = false,
//   });
// }
//
// enum TabKind { upcoming, past, all }
//
// /// ───────────────────────── SCREEN ────────────────────────────────────────────
// class EventsScreen extends StatefulWidget {
//   const EventsScreen({super.key});
//
//   @override
//   State<EventsScreen> createState() => _EventsScreenState();
// }
//
// class _EventsScreenState extends State<EventsScreen> {
//   TabKind _selected = TabKind.upcoming;
//
//   // Anchor to reproduce labels like "Now", "1 day", "4 days"
//   final DateTime _anchor = DateTime(2026, 6, 17);
//
//   // Sample data (matches your screenshot)
//   late final List<Event> _upcoming = [
//     Event(
//       title: 'Body check',
//       start: DateTime(2026, 6, 17, 8),
//       end: DateTime(2026, 6, 17, 9),
//       location: '20, Farm Road',
//       color: const Color(0xFF22C55E),
//       hasBadge: true,
//     ),
//     Event(
//       title: 'Exhibition week',
//       start: DateTime(2026, 6, 18, 8),
//       end: DateTime(2026, 6, 21, 9),
//       location: 'Asia Expo',
//       color: const Color(0xFFF59E0B),
//       hasBadge: true,
//       showTinyIconsRow: true,
//     ),
//     Event(
//       title: 'Family dinner',
//       start: DateTime(2026, 6, 21),
//       location: 'Home',
//       color: const Color(0xFF60A5FA),
//       hasBadge: true,
//       allDay: true,
//     ),
//   ];
//
//   // Simple past/all data (customize as needed)
//   late final List<Event> _past = [
//     Event(
//       title: 'Standup',
//       start: DateTime(2026, 6, 15, 9),
//       end: DateTime(2026, 6, 15, 9, 30),
//       location: 'HQ',
//       color: const Color(0xFF9CA3AF),
//     ),
//   ];
//
//   List<Event> get _all =>
//       [..._upcoming, ..._past]..sort((a, b) => a.start.compareTo(b.start));
//
//   final Set<String> _filters = <String>{}; // brick ids
//
//
//   @override
//   Widget build(BuildContext context) {
//     final list = switch (_selected) {
//     // All tabs now use the **same layout** with timeline pill + card rows
//       TabKind.upcoming => _buildSection(_upcoming),
//       TabKind.past => _buildSection(_past),
//       TabKind.all => _buildSection(_all),
//     };
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             const _TopBar(),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
//               child: CategoryFilterBar(
//                 activeIds: _filters,
//                 onChange: (newSet) => setState(() {
//                   _filters
//                     ..clear()
//                     ..addAll(newSet);
//                 }),
//               ),
//             ),
//             const SizedBox(height: 10),
//             _TabsRow(
//               selected: _selected,
//               onSelect: (t) => setState(() => _selected = t),
//             ),
//             const SizedBox(height: 6),
//             const Divider(height: 1, thickness: 0.3),
//             Expanded(child: list),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Common builder for Upcoming / Past / All (timeline pill + card on SAME ROW)
//   Widget _buildSection(List<Event> events) {
//     String labelFor(DateTime t) {
//       final days = t.difference(_anchor).inDays;
//       if (days == 0) return 'Now';
//       if (days > 0) return days == 1 ? '1 day' : '$days days';
//       final past = days.abs();
//       return past == 1 ? '1 day ago' : '$past days ago';
//     }
//
//     Widget row(String label, Widget card) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // left: the small timeline pill (fixed width so cards align)
//           SizedBox(width: 46, child: _TimelinePill(text: label)),
//           const SizedBox(width: 8),
//           // right: the event card
//           Expanded(child: card),
//         ],
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       itemCount: events.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, i) =>
//           row(labelFor(events[i].start), _eventCardFrom(events[i])),
//     );
//   }
//
//   Widget _eventCardFrom(Event e) {
//     final dateText = _formatDateRange(e.start, e.end);
//     final timeText = e.allDay ? 'All day' : _formatTimeRange(e.start, e.end);
//     return _EventCard(
//       accentColor: e.color,
//       title: e.title,
//       dateText: dateText,
//       timeText: timeText,
//       locationText: e.location,
//       isAllDay: e.allDay,
//       hasBadge: e.hasBadge,
//       showTinyIconsRow: e.showTinyIconsRow,
//     );
//   }
//
//   // formatting helpers
//   static const _months = [
//     'JAN',
//     'FEB',
//     'MAR',
//     'APR',
//     'MAY',
//     'JUN',
//     'JUL',
//     'AUG',
//     'SEP',
//     'OCT',
//     'NOV',
//     'DEC'
//   ];
//   String _fmt12(DateTime t) {
//     var h = t.hour % 12;
//     if (h == 0) h = 12;
//     final m = t.minute.toString().padLeft(2, '0');
//     return '${h.toString().padLeft(2, '0')} : $m ${t.hour >= 12 ? 'PM' : 'AM'}';
//   }
//
//   String _formatDateRange(DateTime start, DateTime? end) {
//     final a =
//         '${start.day.toString().padLeft(2, '0')} ${_months[start.month - 1]} ${start.year}';
//     if (end == null ||
//         (start.year == end.year &&
//             start.month == end.month &&
//             start.day == end.day)) {
//       return a;
//     }
//     final b =
//         '${end.day.toString().padLeft(2, '0')} ${_months[end.month - 1]} ${end.year}';
//     return '$a - $b';
//   }
//
//   String _formatTimeRange(DateTime start, DateTime? end) {
//     if (end == null) return _fmt12(start);
//     return '${_fmt12(start)} - ${_fmt12(end)}';
//   }
// }
//
// /// ───────────────────────── UI CHROME ─────────────────────────────────────────
// class _TopBar extends StatelessWidget {
//   const _TopBar();
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
//       child: Row(
//         children: [
//           const Text(
//             'Events',
//             style:
//             TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                   const MinimalSearchScreen(),
//                   transitionsBuilder: (
//                       context,
//                       animation,
//                       secondaryAnimation,
//                       child,
//                       ) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.easeInOut;
//                     final tween = Tween(
//                       begin: begin,
//                       end: end,
//                     ).chain(CurveTween(curve: curve));
//                     return SlideTransition(
//                       position: animation.drive(tween),
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             },
//             icon: const Icon(
//               CupertinoIcons.search,
//               color: Colors.black,
//             ),
//           ),
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) =>
//                       const NotificationScreen(),
//                       transitionsBuilder: (
//                           context,
//                           animation,
//                           secondaryAnimation,
//                           child,
//                           ) {
//                         const begin = Offset(1.0, 0.0);
//                         const end = Offset.zero;
//                         const curve = Curves.easeInOut;
//                         final tween = Tween(
//                           begin: begin,
//                           end: end,
//                         ).chain(CurveTween(curve: curve));
//                         return SlideTransition(
//                           position: animation.drive(tween),
//                           child: child,
//                         );
//                       },
//                     ),
//                   );
//                 },
//                 icon: const Icon(
//                   CupertinoIcons.bell,
//                   color: Colors.black,
//                 ),
//               ),
//               Positioned(
//                 right: 10,
//                 top: 10,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFFF5757),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                   const SettingsScreen(),
//                   transitionsBuilder: (
//                       context,
//                       animation,
//                       secondaryAnimation,
//                       child,
//                       ) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.easeInOut;
//                     final tween = Tween(
//                       begin: begin,
//                       end: end,
//                     ).chain(CurveTween(curve: curve));
//                     return SlideTransition(
//                       position: animation.drive(tween),
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             },
//             icon: const Icon(
//               Icons.settings_outlined,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CategoryChips extends StatelessWidget {
//   const _CategoryChips();
//
//   @override
//   Widget build(BuildContext context) {
//     final items = <_ChipData>[
//       _ChipData('All', Colors.grey.shade300, Colors.black87, isSolid: false),
//       _ChipData('Home', const Color(0xFF3B82F6), Colors.white),
//       _ChipData('Work', const Color(0xFFF59E0B), Colors.white),
//       _ChipData('School', const Color(0xFFA78BFA), Colors.white),
//       _ChipData('Personal', const Color(0xFF10B981), Colors.white),
//     ];
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           for (final c in items) ...[
//             _PillChip(data: c),
//             const SizedBox(width: 8),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// /// Interactive tabs
// class _TabsRow extends StatelessWidget {
//   final TabKind selected;
//   final ValueChanged<TabKind> onSelect;
//   const _TabsRow({required this.selected, required this.onSelect});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
//       child: Row(
//         children: [
//           _Segment(
//             text: 'Upcoming',
//             selected: selected == TabKind.upcoming,
//             onTap: () => onSelect(TabKind.upcoming),
//           ),
//           const SizedBox(width: 45),
//           _Segment(
//             text: 'Past',
//             selected: selected == TabKind.past,
//             onTap: () => onSelect(TabKind.past),
//           ),
//           const SizedBox(width: 45),
//           _Segment(
//             text: 'All',
//             selected: selected == TabKind.all,
//             onTap: () => onSelect(TabKind.all),
//           ),
//           const Spacer(),
//           const _IconRounded(icon: Icons.tune_rounded),
//         ],
//       ),
//     );
//   }
// }
//
// class _Segment extends StatelessWidget {
//   final String text;
//   final bool selected;
//   final VoidCallback? onTap;
//
//   const _Segment({
//     required this.text,
//     this.selected = false,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const inactiveText = Color(0xFF6B7280);
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: selected ? Colors.black : inactiveText,
//               ),
//             ),
//             const SizedBox(height: 6),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               curve: Curves.easeOut,
//               height: 3,
//               width: selected ? 26 : 0,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(999),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _IconRounded extends StatelessWidget {
//   final IconData icon;
//   const _IconRounded({required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 34,
//       height: 34,
//       decoration: BoxDecoration(
//           color: const Color(0xFFF3F4F6),
//           borderRadius: BorderRadius.circular(10)),
//       child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
//     );
//   }
// }
//
// /// ───────────────────────── CARD (exact design) ───────────────────────────────
// class _EventCard extends StatelessWidget {
//   final Color accentColor;
//   final String title;
//   final String dateText;
//   final String timeText;
//   final String locationText;
//   final bool isAllDay;
//   final bool hasBadge;
//   final bool showTinyIconsRow;
//
//   const _EventCard({
//     super.key,
//     required this.accentColor,
//     required this.title,
//     required this.dateText,
//     required this.timeText,
//     required this.locationText,
//     this.isAllDay = false,
//     this.hasBadge = false,
//     this.showTinyIconsRow = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFFF6F7F9);
//     const stroke = Color(0xFFE8ECF2);
//     const mainText = Color(0xFF0F172A);
//     const subText = Color(0xFF6B7280);
//     const muteIcon = Color(0xFF9AA3AF);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: stroke),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // thin colored rail
//           Container(
//             width: 4,
//             height: 20,
//             margin: const EdgeInsets.only(left: 10, right: 2, top: 4),
//             decoration: BoxDecoration(
//               color: accentColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//
//           // content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // title
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: mainText,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 // date + trailing location
//                 Row(
//                   children: [
//                     const Icon(Icons.calendar_month_outlined,
//                         size: 16, color: muteIcon),
//                     const SizedBox(width: 8),
//                     Text(
//                       dateText,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: subText,
//                       ),
//                     ),
//
//                     const SizedBox(width: 70,),
//
//                     const Icon(Icons.place_outlined,
//                         size: 16, color: muteIcon),
//                     const SizedBox(width: 4),
//                     Text(
//                       locationText,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: subText,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//
//                 // time + TRAILING STRIP (icons + red badge)
//                 Row(
//                   children: [
//                     const Icon(Icons.access_time, size: 16, color: muteIcon),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         timeText,
//                         style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: subText,
//                         ),
//                       ),
//                     ),
//
//                     // —— this whole block is the "red portion" UI —— //
//                     Container(
//                       height: 28,
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (showTinyIconsRow) ...const [
//                             // SizedBox(width: 6),
//                             _CircleIconOutline(
//                                 icon: Icons.comment),
//
//                             // SizedBox(width: 6),
//                             _CircleIconOutline(
//                                 icon: Icons.refresh),
//
//                             // SizedBox(width: 6),
//                             _CircleIconOutline(
//                                 icon: Icons.notifications_none_rounded),
//                             // SizedBox(width: 6),
//                           ],
//                           // menu with red badge
//                           Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               const _CircleIconOutline(icon: CupertinoIcons.list_bullet),
//                               if (hasBadge)
//                                 Positioned(
//                                   right: -2,
//                                   top: -8,
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 5, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFEF4444),
//                                       borderRadius: BorderRadius.circular(999),
//                                     ),
//                                     child: const Text(
//                                       '2',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w800,
//                                         height: 1.0,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     // ———————————————————————————————————————————————— //
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       ),
//     );
//   }
// }
//
// /// Tiny outlined round icon used inside the trailing strip
// class _CircleIconOutline extends StatelessWidget {
//   final IconData icon;
//   const _CircleIconOutline({required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 22,
//       height: 22,
//       alignment: Alignment.center,
//       child: Icon(icon, size: 14, color: const Color(0xFFB0B6C0)),
//     );
//   }
// }
//
// class _ChipData {
//   final String label;
//   final Color color;
//   final Color fg;
//   final bool isSolid;
//   _ChipData(this.label, this.color, this.fg, {this.isSolid = true});
// }
//
// class _PillChip extends StatelessWidget {
//   final _ChipData data;
//   const _PillChip({required this.data});
//   @override
//   Widget build(BuildContext context) {
//     final outlined = !data.isSolid;
//     return Container(
//       height: 28,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: outlined ? Colors.white : data.color.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(999),
//         border: outlined ? Border.all(color: const Color(0xFFE5E7EB)) : null,
//       ),
//       alignment: Alignment.center,
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         if (!outlined)
//           Container(
//             width: 16,
//             height: 16,
//             margin: const EdgeInsets.only(right: 6),
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle, color: Colors.white.withOpacity(0.9)),
//             child: Icon(Icons.check,
//                 size: 12, color: data.color.withOpacity(0.95)),
//           ),
//         Text(
//           data.label,
//           style: TextStyle(
//             color: outlined ? const Color(0xFF4B5563) : data.fg,
//             fontWeight: FontWeight.w700,
//             fontSize: 12,
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// /// The small timeline pill on the left of each card
// class _TimelinePill extends StatelessWidget {
//   final String text;
//   const _TimelinePill({required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: Color(0xFF9AA3AF),
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             height: 1.0,
//           ),
//         ),
//       ),
//     );
//   }
// }
