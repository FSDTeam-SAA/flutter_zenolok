import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/calendar_event.dart';
import '../../data/models/create_event_request_model.dart';
import '../../data/models/create_event_todo_request_model.dart';
import '../../data/models/update_event_request_model.dart';
import '../../domain/repo/event_repo.dart';

class EventController extends GetxController {
  final EventRepo repo;

  EventController(this.repo);

  final RxBool loading = false.obs;

  /// store events grouped by day
  final RxMap<DateTime, List<CalendarEvent>> store =
      <DateTime, List<CalendarEvent>>{}.obs;

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<CalendarEvent> eventsForDay(DateTime day) {
    return store[_dOnly(day)] ?? const [];
  }

  Iterable<CalendarEvent> allEvents() => store.values.expand((e) => e);

  /// ✅ loads month events
  /// FIX:
  /// - update() so GetBuilder rebuilds
  /// - preserve checklist if already loaded / or keep API embedded todos
  Future<void> loadMonth(DateTime focused) async {
    loading.value = true;
    update();

    final oldById = <String, CalendarEvent>{};
    for (final e in allEvents()) {
      oldById[e.id] = e;
    }

    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);

    final res = await repo.listEvents(
      startDate: _fmt(start),
      endDate: _fmt(end),
    );

    res.fold(
      (fail) {
        loading.value = false;
        update();
      },
      (ok) {
        final map = <DateTime, List<CalendarEvent>>{};

        for (final e in ok.data) {
          final prev = oldById[e.id];

          // Prefer already-loaded checklist in memory, otherwise keep API checklist (embedded todos)
          final mergedChecklist = (prev != null && prev.checklist.isNotEmpty)
              ? prev.checklist
              : e.checklist;

          final merged = e.copyWith(checklist: mergedChecklist);

          final k = _dOnly(merged.start);
          map.putIfAbsent(k, () => []).add(merged);
        }

        store.value = map;
        loading.value = false;
        update();
      },
    );
  }

  /// ✅ Create event + todos
  /// FIX:
  /// - Inject checklist immediately into local store so UI shows it right away
  /// - Then create todos on backend
  /// - Then reload todos for that event (optional, but keeps backend as source of truth)
  Future<void> createEventFromUi(CalendarEvent uiEvent) async {
    // -------------------------
    // 1) Compute endTime safely
    // -------------------------
    DateTime endTime;

    if (uiEvent.allDay) {
      final endDay = uiEvent.end ?? uiEvent.start;
      endTime = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
    } else {
      final start = uiEvent.start;
      final rawEnd = uiEvent.end ?? start.add(const Duration(hours: 1));
      endTime = rawEnd.isAfter(start)
          ? rawEnd
          : start.add(const Duration(hours: 1));
    }

    // ----------------------------------------------------
    // 2) Build payloadTodos from checklist ([ ] / [x] text)
    // ----------------------------------------------------
    final payloadTodos = uiEvent.checklist
        .map((raw) {
      final done = raw.startsWith('[x]');
      final text = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '').trim();
      if (text.isEmpty) return null;

      return <String, dynamic>{
        "text": text,
        "isCompleted": done, // change to "completed" if backend needs it
      };
    })
        .whereType<Map<String, dynamic>>()
        .toList();

    // -------------------------
    // 3) Create event request
    // -------------------------
    final req = CreateEventRequestModel(
      title: uiEvent.title,
      brick: uiEvent.categoryId,
      startTime: uiEvent.start,
      endTime: endTime,
      isAllDay: uiEvent.allDay,
      location: uiEvent.location,
      todos: payloadTodos.isEmpty ? null : payloadTodos, // ✅ send to backend
    );

    final createdRes = await repo.createEvent(body: req.toJson());

    await createdRes.fold(
          (fail) async {
        // optional: print(fail.message);
      },
          (ok) async {
        final created = ok.data;
        final k = _dOnly(created.start);

        // ---------------------------------------------------------
        // 4) UI immediate update: show created event + checklist now
        // ---------------------------------------------------------
        final current = List<CalendarEvent>.from(store[k] ?? const []);
        current.add(created.copyWith(checklist: uiEvent.checklist));
        store[k] = current;
        update();

        // ------------------------------------------------------------------
        // 5) Fallback: if backend doesn't create todos from createEvent payload
        // ------------------------------------------------------------------
        // If your backend should return todos but still returns empty,
        // we create them manually via createTodo endpoint.
        final backendReturnedTodos =
            (created.checklist.isNotEmpty) || (payloadTodos.isNotEmpty && (created.checklist.isNotEmpty));

        // Better check (since created.checklist is from client model parse):
        // If API response event has "todos: []" always, then created.checklist will be empty.
        // So we fallback based on UI checklist + "created.todos empty" situation.
        final shouldFallbackCreateTodos = uiEvent.checklist.isNotEmpty &&
            (created.checklist.isEmpty); // created.todos came back empty

        if (shouldFallbackCreateTodos) {
          for (final raw in uiEvent.checklist) {
            final done = raw.startsWith('[x]');
            final text = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '').trim();
            if (text.isEmpty) continue;

            final todoReq = CreateEventTodoRequestModel(
              text: text,
              eventId: created.id,
              isShared: true,
              // if your todo model supports completion state, add it there too:
              // isCompleted: done,
            );

            await repo.createTodo(body: todoReq.toJson());
          }
        }

        // ---------------------------------------------------------
        // 6) Reload todos from backend (DB becomes source of truth)
        // ---------------------------------------------------------
        await loadTodosForEvent(created.id, day: created.start);
      },
    );
  }

  String _normalizeTodoText(String raw) {
    // "[x] test" or "[ ] test" -> "test"
    return raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '').trim().toLowerCase();
  }

  List<Map<String, dynamic>> _buildOnlyNewTodosForPatch({
    required List<String> oldChecklist,
    required List<String> newChecklist,
  }) {
    final oldSet = <String>{};
    for (final r in oldChecklist) {
      final t = _normalizeTodoText(r);
      if (t.isNotEmpty) oldSet.add(t);
    }

    final seen = <String>{};
    final out = <Map<String, dynamic>>[];

    for (final raw in newChecklist) {
      final done = raw.startsWith('[x]');
      final text = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '').trim();
      if (text.isEmpty) continue;

      final key = text.toLowerCase();

      // ✅ avoid duplicates inside same request
      if (seen.contains(key)) continue;
      seen.add(key);

      // ✅ only send NEW todos (not already existing in backend)
      if (oldSet.contains(key)) continue;

      out.add({
        "text": text,
        "isCompleted": done,
        "isShared": true,
      });
    }

    return out;
  }

  CalendarEvent? _findEventInStore(String eventId) {
    for (final entry in store.entries) {
      for (final e in entry.value) {
        if (e.id == eventId) return e;
      }
    }
    return null;
  }

  void _replaceEventInStore(CalendarEvent updated) {
    // remove from all buckets first
    for (final entry in store.entries) {
      entry.value.removeWhere((e) => e.id == updated.id);
    }

    // add to correct day bucket
    final newKey = _dOnly(updated.start);
    final list = List<CalendarEvent>.from(store[newKey] ?? const []);
    list.add(updated);
    store[newKey] = list;
  }



  Future<void> updateEventFromUi(String eventId, CalendarEvent uiEvent) async {
    // 1) compute endTime safely
    DateTime endTime;
    if (uiEvent.allDay) {
      final endDay = uiEvent.end ?? uiEvent.start;
      endTime = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
    } else {
      final start = uiEvent.start;
      final rawEnd = uiEvent.end ?? start.add(const Duration(hours: 1));
      endTime = rawEnd.isAfter(start) ? rawEnd : start.add(const Duration(hours: 1));
    }

    // 2) find existing event in local store (this is what backend already has)
    final existing = _findEventInStore(eventId);
    final oldChecklist = existing?.checklist ?? const [];

    // 3) build ONLY NEW todos to prevent duplicates in backend
    final onlyNewTodos = _buildOnlyNewTodosForPatch(
      oldChecklist: oldChecklist,
      newChecklist: uiEvent.checklist,
    );

    // 4) build update request
    final req = UpdateEventRequestModel(
      title: uiEvent.title,
      brick: uiEvent.categoryId,
      startTime: uiEvent.start,
      endTime: endTime,
      isAllDay: uiEvent.allDay,
      location: uiEvent.location,
      todos: onlyNewTodos.isEmpty ? null : onlyNewTodos, // ✅ only send if new
    );

    // 5) call PATCH
    final res = await repo.updateEvent(
      eventId: eventId,
      body: req.toJson(),
    );

    res.fold(
          (fail) {
        // optional: log fail.message
      },
          (ok) {
        final updatedFromApi = ok.data;

        // 6) IMPORTANT:
        // backend returns the full todos list, but if it doesn't,
        // at least keep UI checklist merged (old + new)
        final mergedChecklist = existing == null
            ? uiEvent.checklist
            : () {
          final all = <String>[];
          all.addAll(existing.checklist);

          // add only new UI todos (so UI stays correct even if backend response not full)
          for (final raw in uiEvent.checklist) {
            final t = _normalizeTodoText(raw);
            final exists = existing.checklist.any((x) => _normalizeTodoText(x) == t);
            if (!exists) all.add(raw);
          }

          return all;
        }();

        final finalEvent = updatedFromApi.copyWith(
          checklist: updatedFromApi.checklist.isNotEmpty
              ? updatedFromApi.checklist
              : mergedChecklist,
        );

        // 7) replace in store (no duplicates)
        _replaceEventInStore(finalEvent);
        update();
      },
    );
  }





  /// ✅ Attach todos to a single event inside store
  Future<void> loadTodosForEvent(
    String eventId, {
    required DateTime day,
  }) async {
    final k = _dOnly(day);
    final list = List<CalendarEvent>.from(store[k] ?? const []);
    final idx = list.indexWhere((e) => e.id == eventId);
    if (idx == -1) return;

    final res = await repo.listTodos(eventId: eventId);

    res.fold((_) {}, (ok) {
      // listTodos returns List<String> (todo text)
      final todos = ok.data.map((t) => '[ ] $t').toList();

      list[idx] = list[idx].copyWith(checklist: todos);
      store[k] = list;
      update();
    });
  }

  /// ✅ Load todos for all events in a day
  Future<void> ensureTodosLoadedForDay(DateTime day) async {
    final k = _dOnly(day);
    final list = List<CalendarEvent>.from(store[k] ?? const []);
    for (final e in list) {
      if (e.checklist.isEmpty) {
        await loadTodosForEvent(e.id, day: e.start);
      }
    }
  }
}
