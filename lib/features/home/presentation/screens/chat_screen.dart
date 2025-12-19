import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/calendar_event.dart';
import '../controller/brick_controller.dart';

// ✅ import CalendarEvent from NEW file (avoids circular import)

// date + time widgets
import '../widgets/date_time_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.event});

  final CalendarEvent event;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _labelGrey = Color(0xFFBFC2CB);
  static const _dividerGrey = Color(0xFFE6E7ED);
  static const _lightIconGrey = Color(0xFFD9DCE4);
  static const _todoBubbleBg = Color(0xFFF5F5F7);
  static const _todoHintGrey = Color(0xFFD2D4DC);

  // editable text
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  final TextEditingController _newTodoCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  late List<_TodoItem> _todos;

  // editable date / time / allDay
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _allDay;

  CalendarEvent get event => widget.event;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: event.title);
    _locationCtrl = TextEditingController(text: event.location ?? '');

    // init checklist
    final rawList = event.checklist.isNotEmpty
        ? event.checklist
        : <String>[
      '[ ] Post ig story',
      '[ ] Leaflet giving',
      '[x] Bring staff pass',
    ];
    _todos = rawList.map(_TodoItem.fromRaw).toList();

    // init date / time
    final start = event.start;
    final end = event.end ?? event.start;

    _startDate = DateTime(start.year, start.month, start.day);
    _endDate = DateTime(end.year, end.month, end.day);
    _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
    _allDay = event.allDay;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _newTodoCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) => DateFormat('d MMM yyyy').format(d).toUpperCase();
  String _fmtDay(DateTime d) => DateFormat('EEEE').format(d);
  String _fmtTime(DateTime d) => DateFormat('hh : mm').format(d);
  String _fmtAmPm(DateTime d) => DateFormat('a').format(d);

  // combine date + time
  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  Future<void> _pickDateRange() async {
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateRangeBottomSheet(
        initialStart: _startDate,
        initialEnd: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
  }

  Future<void> _pickTimeRange() async {
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

  /// "#RRGGBB" or "#AARRGGBB" -> Color
  Color _hexToColor(String hex, {Color fallback = const Color(0xFF3AA1FF)}) {
    final raw = hex.replaceAll('#', '').trim();
    if (raw.length == 6) {
      return Color(int.parse('FF$raw', radix: 16));
    }
    if (raw.length == 8) {
      return Color(int.parse(raw, radix: 16));
    }
    return fallback;
  }

  BrickModel? _brickById(List<BrickModel> bricks, String id) {
    for (final b in bricks) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// maps your stored iconKey -> IconData (same list you use in editor)
  IconData _iconFromKey(String key) {
    const map = <String, IconData>{
      'ri-focus-2-fill': Icons.work_outline,
      'ri-home-4-line': Icons.home_outlined,
      'ri-book-3-line': Icons.school_outlined,
      'ri-heart-3-line': Icons.favorite_border,
      'ri-football-line': Icons.sports_soccer_outlined,
      'ri-cup-line': Icons.local_cafe_outlined,
      'ri-book-open-line': Icons.book_outlined,
      'ri-flight-takeoff-line': Icons.flight_outlined,
      'ri-shopping-bag-3-line': Icons.shopping_bag_outlined,
      'ri-music-2-line': Icons.music_note_outlined,
      'ri-movie-2-line': Icons.movie_outlined,
      'ri-dumbbell-line': Icons.fitness_center_outlined,
      'ri-bear-smile-line': Icons.pets_outlined,
      'ri-camera-3-line': Icons.camera_alt_outlined,
      'ri-computer-line': Icons.computer_outlined,
      'ri-restaurant-2-line': Icons.restaurant_outlined,
      'ri-hotel-bed-line': Icons.bed_outlined,
      'ri-sun-line': Icons.beach_access_outlined,
      'ri-calendar-event-line': Icons.event_outlined,
      'ri-alarm-line': Icons.alarm_outlined,
      'ri-bike-line': Icons.directions_bike_outlined,
      'ri-bus-line': Icons.directions_bus_outlined,
      'ri-hospital-line': Icons.local_hospital_outlined,
      'ri-lightbulb-line': Icons.lightbulb_outline,
      'ri-star-line': Icons.star_border,
      'ri-layout-grid-line': Icons.workspaces_outline,
      'ri-puzzle-line': Icons.extension_outlined,
      'ri-brush-line': Icons.brush_outlined,
      'ri-car-line': Icons.drive_eta_outlined,
      'ri-gamepad-line': Icons.games_outlined,
      'ri-cake-3-line': Icons.emoji_food_beverage_outlined,
    };
    return map[key] ?? Icons.work_outline;
  }

  void _onSave() {
    // build new start / end based on allDay + selections
    late DateTime start;
    DateTime? end;

    if (_allDay) {
      start = DateTime(_startDate.year, _startDate.month, _startDate.day);
      if (_startDate.isAtSameMomentAs(_endDate)) {
        end = null; // single all-day
      } else {
        end = DateTime(_endDate.year, _endDate.month, _endDate.day);
      }
    } else {
      start = _combine(_startDate, _startTime);
      end = _combine(_endDate, _endTime);
    }

    final updated = CalendarEvent(
      id: event.id,
      categoryId: event.categoryId, // ✅ keep brick category
      title: _titleCtrl.text.trim().isEmpty ? event.title : _titleCtrl.text.trim(),
      start: start,
      end: end,
      allDay: _allDay,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      checklist: _todos
          .map((t) => '${t.checked ? "[x]" : "[ ]"} ${t.label}')
          .toList(),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;

    final BrickController controller = Get.find<BrickController>();

    // ✅ resolve brick from event.categoryId
    final BrickModel? brick = _brickById(controller.bricks, event.categoryId);

    // ✅ fallback if brick not loaded yet
    final Color categoryColor =
    brick != null ? _hexToColor(brick.color) : const Color(0xFF3AA1FF);
    final String categoryLabel = brick?.name ?? 'Category';
    final IconData categoryIcon =
    brick != null ? _iconFromKey(brick.icon) : Icons.work_outline;

    final startDate = _startDate;
    final endDate = _endDate;

    final startDT = _combine(startDate, _startTime);
    final endDT = _combine(endDate, _endTime);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 22,
              color: Color(0xFFFF4B5C),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.check_rounded,
              size: 22,
              color: Color(0xFF3AC3FF),
            ),
            onPressed: _onSave,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          // title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.share_outlined,
                size: 18,
                color: _lightIconGrey,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // category pill
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoryIcon,
                    size: 14,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    categoryLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          // DATE ROW
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickDateRange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.event_outlined, size: 20, color: _labelGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fmtDay(startDate),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _labelGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtDate(startDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtDay(endDate),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _labelGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtDate(endDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.notifications_none_rounded,
                    size: 18, color: _lightIconGrey),
                const SizedBox(width: 12),
                const Icon(Icons.autorenew_rounded,
                    size: 18, color: _lightIconGrey),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // TIME ROW
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _allDay ? null : _pickTimeRange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 20, color: _labelGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fmtTime(startDT),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtAmPm(startDT),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _labelGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtTime(endDT),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtAmPm(endDT),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _labelGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _allDay = !_allDay;
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _allDay ? const Color(0xFFF6F7FA) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7E8EE)),
                    ),
                    child: const Text(
                      'All day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD0D3DD),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: _dividerGrey),

          // LOCATION
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.place_outlined, size: 20, color: _labelGrey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Location',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          _buildTodoBubble(categoryColor),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline_rounded, size: 16, color: _labelGrey),
              SizedBox(width: 4),
              Text(
                "Let's JAM",
                style: TextStyle(
                  fontSize: 13,
                  color: _labelGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: _labelGrey),
            ],
          ),
        ],
      ),
    );
  }

  // todo bubble --------------------------------------------------------------

  Widget _buildTodoBubble(Color highlightColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      decoration: BoxDecoration(
        color: _todoBubbleBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _todos.length; i++) ...[
            _TodoRadioRow(
              label: _todos[i].label,
              selected: _todos[i].checked,
              highlightColor: highlightColor,
              onTap: () {
                setState(() {
                  for (int j = 0; j < _todos.length; j++) {
                    _todos[j] =
                        _todos[j].copyWith(checked: j == i ? true : false);
                  }
                });
              },
            ),
            if (i != _todos.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _newTodoCtrl,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'New todo',
              hintStyle: TextStyle(
                fontSize: 13,
                color: _todoHintGrey,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty) return;
              setState(() {
                _todos.add(_TodoItem(label: trimmed, checked: false));
                _newTodoCtrl.clear();
              });
            },
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: const Color(0xFFE1E2E8)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'New notes',
              hintStyle: TextStyle(
                fontSize: 11,
                color: _todoHintGrey,
              ),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _TodoRadioRow extends StatelessWidget {
  const _TodoRadioRow({
    required this.label,
    required this.selected,
    required this.highlightColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color highlightColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? highlightColor : const Color(0xFFCDCFD7);
    final fillColor = selected ? highlightColor : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: selected
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoItem {
  final String label;
  final bool checked;

  const _TodoItem({required this.label, required this.checked});

  factory _TodoItem.fromRaw(String raw) {
    final checked = raw.startsWith('[x]');
    final label = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '');
    return _TodoItem(label: label, checked: checked);
  }

  _TodoItem copyWith({String? label, bool? checked}) {
    return _TodoItem(
      label: label ?? this.label,
      checked: checked ?? this.checked,
    );
  }
}
