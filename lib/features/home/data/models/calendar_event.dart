class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final String? location;

  /// ✅ dynamic category from API bricks
  final String categoryId;

  final List<String> checklist;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.allDay = false,
    this.location,
    required this.categoryId,
    this.checklist = const [],
  });
}
