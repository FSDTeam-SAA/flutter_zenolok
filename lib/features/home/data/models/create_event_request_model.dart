class CreateEventRequestModel {
  final String title;
  final String brick;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final String? notes; // ✅ NEW

  final List<Map<String, dynamic>>? todos;

  CreateEventRequestModel({
    required this.title,
    required this.brick,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.location,
    this.notes,
    this.todos,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "brick": brick,
      "startTime": startTime.toUtc().toIso8601String(),
      "endTime": endTime.toUtc().toIso8601String(),
      "isAllDay": isAllDay,
      "location": location,
      if (notes != null) "notes": notes, // ✅ NEW
      if (todos != null) "todos": todos,
    };
  }
}


