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

  factory CalendarEvent.fromApi(Map<String, dynamic> json) {
    final start = DateTime.parse(json['startTime']).toLocal();
    final endRaw = json['endTime'];
    final end = endRaw == null ? null : DateTime.parse(endRaw).toLocal();

    return CalendarEvent(
      id: (json['id'] ?? json['_id']).toString(),
      title: (json['title'] ?? '').toString(),
      start: start,
      end: end,
      allDay: (json['isAllDay'] ?? false) == true,
      location: json['location']?.toString(),
      categoryId: (json['brick'] ?? json['brickId'] ?? json['categoryId']).toString(),
      checklist: const [], // load from event-todos endpoint
    );
  }

  CalendarEvent copyWith({List<String>? checklist}) {
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



// class CalendarEvent {
//   final String id;
//   final String title;
//   final DateTime start;
//   final DateTime? end;
//   final bool allDay;
//   final String? location;
//
//   /// ✅ dynamic category from API bricks
//   final String categoryId;
//
//   final List<String> checklist;
//
//   const CalendarEvent({
//     required this.id,
//     required this.title,
//     required this.start,
//     this.end,
//     this.allDay = false,
//     this.location,
//     required this.categoryId,
//     this.checklist = const [],
//   });
// }
