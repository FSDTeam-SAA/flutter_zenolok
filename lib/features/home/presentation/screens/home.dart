import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/widgets/bottom_action_bar.dart';
import 'package:flutter_zenolok/features/home/presentation/widgets/calendar_header.dart';
import 'package:flutter_zenolok/features/home/presentation/widgets/calendar_section.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/calendar_event.dart';
import '../controller/brick_controller.dart';
import '../controller/event_controller.dart';
import '../widgets/calendar_helpers.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/date_time_widget.dart';
import '../widgets/event_pane.dart';
import 'category_editor_screen.dart';

class CalendarHomePage extends StatefulWidget {
  const CalendarHomePage({super.key});

  @override
  State<CalendarHomePage> createState() => _CalendarHomePageState();
}

class _CalendarHomePageState extends State<CalendarHomePage> {
  final ValueNotifier<DateTime> _focused = ValueNotifier(DateTime.now());
  DateTime? _selected = CalendarHelpers.dateOnly(DateTime.now());
  final CalendarFormat _format = CalendarFormat.month;

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
    final k = CalendarHelpers.dateOnly(day);

    final List<CalendarEvent> exact = Get.find<EventController>().eventsForDay(
      k,
    );

    final spanning = _allEventsFromController().where(
      (e) => CalendarHelpers.isMultiDayAllDay(e) && CalendarHelpers.betweenIncl(day, e.start, e.end!),
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
      (e) => CalendarHelpers.isMultiDayAllDay(e) && CalendarHelpers.betweenIncl(day, e.start, e.end!),
    );
  }

  Future<void> _addEvent(CalendarEvent e) async {
    await Get.find<EventController>().createEventFromUi(e);

    setState(() {
      _selected = CalendarHelpers.dateOnly(e.start);
      _focused.value = CalendarHelpers.dateOnly(e.start);
    });

    await Get.find<EventController>().ensureTodosLoadedForDay(_selected!);
  }

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
        _selected = CalendarHelpers.dateOnly(result.start);
      });

      Get.find<EventController>().loadMonth(result.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? CalendarHelpers.dateOnly(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CalendarHeader(
                focusedDate: _focused.value,
                onTitleTap: _openHeaderDatePicker,
              ),

              const SizedBox(height: 2),

              //for category
              SizedBox(
                height: 26,
                child: SizedBox(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
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
                  ),
                ),
              ),

              // Calendar + Event list rebuild on controller update
              GetBuilder<EventController>(
                builder: (_) {
                  return Column(
                    children: [
                      CalendarSection(
                        focusedDay: _focused.value,
                        selectedDay: _selected,
                        format: _format,
                        onPageChanged: (d) async {
                          setState(() => _focused.value = d);
                          await Get.find<EventController>().loadMonth(d);

                          if (_selected != null) {
                            await Get.find<EventController>()
                                .ensureTodosLoadedForDay(_selected!);
                          }
                        },
                        onDaySelected: (sel, foc) async {
                          setState(() {
                            _selected = CalendarHelpers.dateOnly(sel);
                            _focused.value = foc;
                          });

                          await Get.find<EventController>()
                              .ensureTodosLoadedForDay(_selected!);
                        },
                        eventLoader: _eventsFor,
                        isStreakDay: _isStreakDay,
                      ),

                      BottomActionBar(
                        selectedDate: _selected ?? DateTime.now(),
                        onTodayTap: () => setState(() {
                          _focused.value = DateTime.now();
                          _selected = CalendarHelpers.dateOnly(DateTime.now());
                        }),
                        onAddEvent: (e) => _addEvent(e),
                      ),

                      // day’s events list
                      EventPane(
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
