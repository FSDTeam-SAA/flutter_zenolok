import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/calendar_event.dart';
import '../../data/models/create_event_request_model.dart';
import '../../data/models/create_event_todo_request_model.dart';
import '../../domain/repo/event_repo.dart';

class EventController extends GetxController {
  final EventRepo repo;
  EventController(this.repo);

  final RxBool loading = false.obs;

  // store events grouped by day
  final RxMap<DateTime, List<CalendarEvent>> store = <DateTime, List<CalendarEvent>>{}.obs;

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> loadMonth(DateTime focused) async {
    loading.value = true;

    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);

    final res = await repo.listEvents(
      startDate: _fmt(start),
      endDate: _fmt(end),
    );

    res.fold(
          (fail) {
        loading.value = false;
      },
          (ok) {
        final map = <DateTime, List<CalendarEvent>>{};
        for (final e in ok.data) {
          final k = _dOnly(e.start);
          map.putIfAbsent(k, () => []).add(e);
        }
        store.value = map;
        loading.value = false;
      },
    );
  }

  List<CalendarEvent> eventsForDay(DateTime day) {
    return store[_dOnly(day)] ?? const [];
  }

  /// Create event + todos (same flow as Postman)
  Future<void> createEventFromUi(CalendarEvent uiEvent) async {
    // API needs endTime always
    final endTime = uiEvent.end ??
        (uiEvent.allDay
            ? DateTime(uiEvent.start.year, uiEvent.start.month, uiEvent.start.day, 23, 59, 59)
            : uiEvent.start.add(const Duration(hours: 1)));

    final req = CreateEventRequestModel(
      title: uiEvent.title,
      brick: uiEvent.categoryId,
      startTime: uiEvent.start,
      endTime: endTime,
      isAllDay: uiEvent.allDay,
      location: uiEvent.location,
    );

    final createdRes = await repo.createEvent(body: req.toJson());

    await createdRes.fold(
          (fail) async {},
          (ok) async {
        final created = ok.data;
        final k = _dOnly(created.start);

        final current = List<CalendarEvent>.from(store[k] ?? const []);
        current.add(created);
        store[k] = current;

        // create todos
        for (final raw in uiEvent.checklist) {
          final text = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '').trim();
          if (text.isEmpty) continue;

          final todoReq = CreateEventTodoRequestModel(
            text: text,
            eventId: created.id,
            isShared: true,
          );
          await repo.createTodo(body: todoReq.toJson());
        }

        // reload todos for that event (optional)
        await loadTodosForEvent(created.id, day: created.start);
      },
    );
  }

  Future<void> loadTodosForEvent(String eventId, {required DateTime day}) async {
    final k = _dOnly(day);
    final list = List<CalendarEvent>.from(store[k] ?? const []);
    final idx = list.indexWhere((e) => e.id == eventId);
    if (idx == -1) return;

    final res = await repo.listTodos(eventId: eventId);
    res.fold((_) {}, (ok) {
      final todos = ok.data.map((t) => '[ ] $t').toList();
      list[idx] = list[idx].copyWith(checklist: todos);
      store[k] = list;
    });
  }
}
