class CreateEventRequestModel {
  final String title;
  final String brick; // brickId
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final DateTime? reminder;
  final String? recurrence;

  CreateEventRequestModel({
    required this.title,
    required this.brick,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.location,
    this.reminder,
    this.recurrence,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "brick": brick,
      "startTime": startTime.toUtc().toIso8601String(),
      "endTime": endTime.toUtc().toIso8601String(),
      "isAllDay": isAllDay,
      if (location != null) "location": location,
      if (reminder != null) "reminder": reminder!.toUtc().toIso8601String(),
      if (recurrence != null) "recurrence": recurrence,
    };
  }
}
