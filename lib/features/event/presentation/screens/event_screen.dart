import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../home/data/models/calendar_event.dart';
import '../../../home/presentation/controller/event_controller.dart';
import '../../../home/presentation/controller/brick_controller.dart';

import '../../../home/presentation/screens/home.dart';
import '../../../home/presentation/screens/notification_screen.dart';
import '../../../home/presentation/screens/searchScreen.dart';
import '../../../home/presentation/screens/setting_screen.dart';

import '../../../home/presentation/widgets/category_filter_bar.dart';
import '../../../home/presentation/widgets/cateogry_widget.dart'; // ✅ contains CategoryEditorScreen (as you use it)

// ✅ IMPORTANT:
// EventsScreen will navigate to EventEditorScreen (the editor you showed in your example).
// Make sure EventEditorScreen is accessible here via an import.
// If you already have it in a separate file, import it instead of this comment.
//
// Example (change path to your real file):
// import '../../../home/presentation/screens/event_editor_screen.dart';

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

  DateTime get _anchor => DateTime.now();

  // ✅ Single-select category behavior (same as your editor)
  Set<String> _editorFilters = <String>{};
  String? _selectedBrickId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final eventC = Get.find<EventController>();
      final brickC = Get.find<BrickController>();

      // initial events load (tab = upcoming by default)
      eventC.refreshEventsUI();

      // load bricks then select default
      await brickC.loadBricks();
      final bricks = brickC.bricks;

      if (_selectedBrickId == null && bricks.isNotEmpty) {
        final lastId = bricks.last.id;
        setState(() {
          _selectedBrickId = lastId;
          _editorFilters = {lastId};
        });

        eventC.applyBrickFiltersUI(_editorFilters);
      }
    });
  }

  Future<void> _openEdit(CalendarEvent original) async {
    // ✅ open editor (same signature as your example)
    final edited = await Navigator.of(context).push<CalendarEvent>(
      PageRouteBuilder<CalendarEvent>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EventEditorScreen(
            initialDate: original.start,
            existingEvent: original,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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

    if (edited == null) return;

    final ec = Get.find<EventController>();

    // ✅ update backend/store using SAME id
    await ec.updateEventFromUi(original.id, edited);

    // ✅ refresh list and keep current tab + filters
    await ec.refreshEventsUI();
    await ec.changeTabUI(_selected);
    ec.applyBrickFiltersUI(_editorFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<EventController>(
          builder: (controller) {
            final List<CalendarEvent> apiEvents =
                controller.eventsForSelectedTabFlat;

            final List<Event> uiEvents = apiEvents.map(_mapToUiEvent).toList();

            return Column(
              children: [
                const _TopBar(),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
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

                      controller.applyBrickFiltersUI(_editorFilters);
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

                        controller.applyBrickFiltersUI(_editorFilters);
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                _TabsRow(
                  selected: _selected,
                  onSelect: (t) async {
                    setState(() => _selected = t);
                    await controller.changeTabUI(t);
                  },
                ),

                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.3),

                Expanded(
                  child: controller.loading.value
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSection(
                          uiEvents,
                          // ✅ Pass the ORIGINAL apiEvents so we can open editor with CalendarEvent
                          apiEvents: apiEvents,
                          onTapApiEvent: _openEdit,
                        ),
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
    final hex = _getBrickColorHex(e);
    final color = _hexToColorSafe(hex);

    final hasTodos = e.checklist.isNotEmpty;

    return Event(
      title: e.title,
      start: e.start,
      end: e.end,
      location: _getLocationSafe(e),
      color: color,
      allDay: e.allDay,
      showTinyIconsRow: hasTodos,
      hasBadge: hasTodos,
    );
  }

  String _getBrickColorHex(CalendarEvent e) {
    try {
      final dyn = e as dynamic;
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
    final value =
        int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16) ??
        0xFF9CA3AF;
    return Color(value);
  }

  /// Common builder (timeline pill + card on SAME ROW)
  Widget _buildSection(
    List<Event> events, {
    required List<CalendarEvent> apiEvents,
    required Future<void> Function(CalendarEvent e) onTapApiEvent,
  }) {
    String labelFor(DateTime t) {
      final days = t.difference(_anchor).inDays;
      if (days == 0) return 'Now';
      if (days > 0) return days == 1 ? '1 day' : '$days days';
      final past = days.abs();
      return past == 1 ? '1 day ago' : '$past days ago';
    }

    Widget row({required String label, required Widget card}) {
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
      itemBuilder: (context, i) {
        final ui = events[i];
        final api = apiEvents[i]; // ✅ same index order (mapped from apiEvents)

        return row(
          label: labelFor(ui.start),
          card: _eventCardFrom(
            ui,
            onTap: () => onTapApiEvent(api), // ✅ CLICK -> EDIT
          ),
        );
      },
    );
  }

  Widget _eventCardFrom(Event e, {VoidCallback? onTap}) {
    final dateText = _formatDateRange(e.start, e.end);
    final timeText = e.allDay ? 'All day' : _formatTimeRange(e.start, e.end);

    return _EventCard(
      onTap: onTap,
      // ✅ clickable
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
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
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

/// ───────────────────────── UI CHROME ─────────────────────────────────────────
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

  const _Segment({required this.text, this.selected = false, this.onTap});

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
/// ───────────────────────── CARD (your design) ───────────────────────────────
///
/// ───────────────────────── CARD (your design) ───────────────────────────────
class _EventCard extends StatelessWidget {
  final VoidCallback? onTap;

  final Color accentColor; // not used for bar color anymore, but kept so API doesn't break
  final String title;
  final String dateText;
  final String timeText;
  final String locationText;
  final bool isAllDay;
  final bool hasBadge;
  final bool showTinyIconsRow;

  const _EventCard({
    super.key,
    this.onTap,
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

    // ── detect range vs single date from text ────────────────────────────────
    final parts = dateText.split(' - ');
    final bool isRange = parts.length == 2;

    // ── choose bar color ─────────────────────────────────────────────────────
    // all-day  -> stroke (grey)
    // range    -> red
    // single   -> green
    final Color barColor;
    if (isAllDay) {
      barColor = const Color(0xFF34C759); // green for single timed event
    } else if (isRange) {
      barColor = const Color(0xFFFFCC00); // red for streak / range
    } else {


      barColor = const Color(0xFFFFCC00);
    }

    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // small left padding so the bar is inside the rounded card
            const SizedBox(width: 4),

            // everything else (bar + text + icons)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────── TITLE ROW: BAR + TITLE + HANDLE ─────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ✅ vertical color bar just before text
                      Container(
                        width: 4,
                        height: 18,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: barColor, // ← dynamic color
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),

                      // title text
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: mainText,
                          ),
                        ),
                      ),


                    ],
                  ),

                  const SizedBox(height: 8),

                  // ───────── DATE + LOCATION ROW ─────────
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 16, color: muteIcon),
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
                      const Icon(Icons.place_outlined,
                          size: 16, color: muteIcon),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ───────── TIME + SMALL ICONS ROW ─────────
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: muteIcon),
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
                              _CircleIconOutline(
                                  icon: Icons.notifications_none_rounded),
                            ],
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const _CircleIconOutline(
                                    icon: CupertinoIcons.list_bullet),
                                if (hasBadge)
                                  Positioned(
                                    right: -2,
                                    top: -8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius:
                                        BorderRadius.circular(999),
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

    // ✅ CLICKABLE CARD -> EDIT
    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
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
