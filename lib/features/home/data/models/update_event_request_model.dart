class UpdateEventRequestModel {
  final String? title;
  final String? brick;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? isAllDay;
  final String? location;

  /// PATCH /events/:id expects todos: [{text,isCompleted,isShared}]
  /// We will send ONLY NEW todos to avoid backend duplicates.
  final List<Map<String, dynamic>>? todos;

  UpdateEventRequestModel({
    this.title,
    this.brick,
    this.startTime,
    this.endTime,
    this.isAllDay,
    this.location,
    this.todos,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) "title": title,
      if (brick != null) "brick": brick,
      if (startTime != null) "startTime": startTime!.toUtc().toIso8601String(),
      if (endTime != null) "endTime": endTime!.toUtc().toIso8601String(),
      if (isAllDay != null) "isAllDay": isAllDay,
      if (location != null) "location": location,

      // ✅ IMPORTANT: only send todos if we have new ones
      if (todos != null && todos!.isNotEmpty) "todos": todos,
    };
  }
}
