class CreateEventTodoRequestModel {
  final String text;
  final String eventId;
  final bool isShared;

  CreateEventTodoRequestModel({
    required this.text,
    required this.eventId,
    this.isShared = true,
  });

  Map<String, dynamic> toJson() => {
    "text": text,
    "eventId": eventId,
    "isShared": isShared,
  };
}
