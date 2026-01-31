import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/calendar_event.dart';
import '../controller/brick_controller.dart';
import '../widgets/all_day_pill.dart';
import '../widgets/calendar_helpers.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/date_time_widget.dart';
import '../widgets/editor_row.dart';
import '../widgets/lets_jam_row.dart';
import '../widgets/todo_bubble.dart';
import 'category_editor_screen.dart';

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

  DateTime _startDate = CalendarHelpers.dateOnly(DateTime.now());
  DateTime _endDate = CalendarHelpers.dateOnly(DateTime.now());

  bool _allDay = true;
  bool _multiDay = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  bool _isSameDay(DateTime a, DateTime b) {
    final da = CalendarHelpers.dateOnly(a);
    final db = CalendarHelpers.dateOnly(b);
    return da.isAtSameMomentAs(db);
  }

  @override
  void initState() {
    super.initState();

    final e = widget.existingEvent;

    if (e == null) {
      _startDate = CalendarHelpers.dateOnly(widget.initialDate);
      _endDate = _startDate;

      _editorFilters = <String>{};
      _selectedBrickId = null;
      return;
    }

    _title.text = e.title;
    _location.text = e.location ?? '';

    _todos
      ..clear()
      ..addAll(e.checklist);

    _selectedBrickId = e.categoryId;
    _editorFilters = {e.categoryId};

    _allDay = e.allDay;

    if (_allDay) {
      _startDate = CalendarHelpers.dateOnly(e.start);

      if (e.end != null && !_isSameDay(e.start, e.end!)) {
        _multiDay = true;
        _endDate = CalendarHelpers.dateOnly(e.end!);
      } else {
        _multiDay = false;
        _endDate = _startDate;
      }
    } else {
      _multiDay = false;
      _startDate = CalendarHelpers.dateOnly(e.start);
      _endDate = _startDate;

      _startTime = TimeOfDay.fromDateTime(e.start);

      final fallbackEnd = e.start.add(const Duration(hours: 1));
      _endTime = TimeOfDay.fromDateTime(e.end ?? fallbackEnd);

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
    final fmt = DateFormat('MMM d');
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
        _startDate = CalendarHelpers.dateOnly(result.start);
        _endDate = CalendarHelpers.dateOnly(result.end);

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
      builder: (_) =>
          TimeRangeBottomSheet(initialStart: _startTime, initialEnd: _endTime),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

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
            icon: const Icon(CupertinoIcons.delete, color: Color(0xFFFF4B5C)),
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
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: GoogleFonts.dongle(
                        fontWeight: FontWeight.w400,
                        fontSize: 33,
                        height: 16 / 33,
                        letterSpacing: 0,
                        color: const Color(0xFFD5D5D5),
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.dongle(
                      fontWeight: FontWeight.w400,
                      fontSize: 33,
                      height: 16 / 33,
                      letterSpacing: 0,
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
            EditorRow(
              icon: Icons.event_outlined,
              label: 'Date',
              labelColor: labelColor,
              expandMiddle: true,
              middleChild: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _dateTextSingleLine(),
                  style: GoogleFonts.dongle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 16 / 16,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
              ),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleIconButton(icon: Icons.notifications_none_rounded),
                  SizedBox(width: 8),
                  CircleIconButton(icon: Icons.autorenew_rounded),
                ],
              ),
              onTap: _openDateRangePicker,
            ),
            const Divider(color: dividerColor, height: 16),
            EditorRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              labelColor: Colors.black,
              expandMiddle: true,
              middleChild: _allDay
                  ? Text(
                      'All day',
                      style: GoogleFonts.dongle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 16 / 20,
                        letterSpacing: 0,
                        color: Colors.black.withValues(alpha: .55),
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
                              DateFormat(
                                'hh : mm a',
                              ).format(_combine(_startDate, _startTime)),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dongle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                height: 16 / 20,
                                letterSpacing: 0,
                                color: const Color(0xFFB6B5B5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '—',
                          style: GoogleFonts.dongle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            height: 16 / 20,
                            letterSpacing: 0,
                            color: const Color(0xFFB6B5B5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat(
                                'hh : mm a',
                              ).format(_combine(_startDate, _endTime)),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dongle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                height: 16 / 20,
                                letterSpacing: 0,
                                color: const Color(0xFFB6B5B5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              trailing: AllDayPill(value: _allDay, onChanged: _setAllDay),
              onTap: !_allDay ? _openTimeRangePicker : null,
            ),
            const Divider(color: dividerColor, height: 16),
            EditorRow(
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
                  hintStyle: GoogleFonts.dongle(
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    height: 16 / 24,
                    letterSpacing: 0,
                    color: const Color(0xFFD5D5D5),
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.dongle(
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  height: 16 / 24,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TodoBubble(
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
            const SizedBox(height: 20),
            const Divider(
              color: dividerColor,
              height: 16,
              thickness: 1.5,
              indent: 24,
              endIndent: 24,
            ),
            Align(
              alignment: Alignment.center,
              child: LetsJamRow(
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
