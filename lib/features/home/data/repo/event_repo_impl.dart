import 'package:dartz/dartz.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/models/network_failure.dart';
import '../../../../core/network/models/network_success.dart';

import '../../domain/repo/event_repo.dart';
import '../models/calendar_event.dart';

class EventRepoImpl implements EventRepo {
  final ApiClient _apiClient;
  EventRepoImpl(this._apiClient);

  @override
  Future<Either<NetworkFailure, NetworkSuccess<List<CalendarEvent>>>> listEvents({
    required String startDate,
    required String endDate,
  }) {
    return _apiClient.get<List<CalendarEvent>>(
      ApiConstants.events.list,
      queryParameters: {
        "startDate": startDate,
        "endDate": endDate,
      },
      fromJsonT: (json) {
        // BaseResponse.data will arrive here
        final List list = (json is List) ? json : (json['data'] ?? json['events'] ?? []);
        return list
            .map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<CalendarEvent>>> createEvent({
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post<CalendarEvent>(
      ApiConstants.events.create,
      data: body,
      fromJsonT: (json) => CalendarEvent.fromApi(Map<String, dynamic>.from(json)),
    );
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<List<String>>>> listTodos({
    required String eventId,
  }) {
    return _apiClient.get<List<String>>(
      ApiConstants.eventTodos.listByEvent(eventId),
      fromJsonT: (json) {
        final List list = (json is List) ? json : (json['data'] ?? json['todos'] ?? []);
        return list.map((e) {
          final m = Map<String, dynamic>.from(e);
          return (m['text'] ?? '').toString();
        }).where((t) => t.trim().isNotEmpty).toList();
      },
    );
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<void>>> createTodo({
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post<void>(
      ApiConstants.eventTodos.create,
      data: body,
      fromJsonT: (_) => null,
    );
  }
}
