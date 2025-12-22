class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final String? location;
  final String categoryId; // brickId
  final List<String> checklist;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    required this.allDay,
    this.location,
    required this.categoryId,
    this.checklist = const [],
  });

  static String _extractBrickId(dynamic brickField) {
    if (brickField == null) return '';

    if (brickField is String) return brickField;

    if (brickField is Map) {
      final m = Map<String, dynamic>.from(brickField);
      final id = m['_id'] ?? m['id'];
      return id?.toString() ?? '';
    }

    return brickField.toString();
  }


  // static List<String> _parseTodos(dynamic rawTodos) {
  //   if (rawTodos == null) return const [];
  //
  //   if (rawTodos is! List) return const [];
  //
  //   final out = <String>[];
  //
  //   for (final item in rawTodos) {
  //     if (item is String) {
  //       final t = item.trim();
  //       if (t.isNotEmpty) out.add('[ ] $t');
  //       continue;
  //     }
  //
  //     if (item is Map) {
  //       final m = Map<String, dynamic>.from(item);
  //       final text = (m['text'] ?? m['title'] ?? m['name'] ?? '').toString().trim();
  //       if (text.isEmpty) continue;
  //
  //       final done = (m['isCompleted'] ??
  //           m['completed'] ??
  //           m['isDone'] ??
  //           m['done'] ??
  //           m['isChecked']) ==
  //           true;
  //
  //       out.add('${done ? '[x]' : '[ ]'} $text');
  //       continue;
  //     }
  //   }
  //
  //   return out;
  // }

  static List<String> _parseTodos(dynamic rawTodos) {
    if (rawTodos == null || rawTodos is! List) return const [];

    final out = <String>[];

    for (final item in rawTodos) {
      if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        final text = (m['text'] ?? '').toString().trim();
        if (text.isEmpty) continue;

        final done = (m['isCompleted'] ?? false) == true;
        out.add('${done ? "[x]" : "[ ]"} $text');
      } else if (item is String) {
        final t = item.trim();
        if (t.isNotEmpty) out.add('[ ] $t');
      }
    }
    return out;
  }


  factory CalendarEvent.fromApi(Map<String, dynamic> json) {
    final start = DateTime.parse(json['startTime']).toLocal();

    final endRaw = json['endTime'];
    final end = endRaw == null ? null : DateTime.parse(endRaw).toLocal();

    final brickId = _extractBrickId(
      json['brick'] ?? json['brickId'] ?? json['categoryId'],
    );

    return CalendarEvent(
      id: (json['id'] ?? json['_id']).toString(),
      title: (json['title'] ?? '').toString(),
      start: start,
      end: end,
      allDay: (json['isAllDay'] ?? false) == true,
      location: json['location']?.toString(),
      categoryId: brickId,
      // ✅ IMPORTANT: read todos if API returns them
      checklist: _parseTodos(json['todos']),
    );
  }

  CalendarEvent copyWith({
    List<String>? checklist,
  }) {
    return CalendarEvent(
      id: id,
      title: title,
      start: start,
      end: end,
      allDay: allDay,
      location: location,
      categoryId: categoryId,
      checklist: checklist ?? this.checklist,
    );
  }
}





