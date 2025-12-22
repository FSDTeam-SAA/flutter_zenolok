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


        dynamic raw = json;

        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);

          // if {data: {...}} or {data: [...]}
          raw = m['data'] ?? raw;

          // if now it's still a map and contains todos
          if (raw is Map) {
            final m2 = Map<String, dynamic>.from(raw);
            raw = m2['todos'] ?? m2['items'] ?? [];
          }
        }

        final list = (raw is List) ? raw : <dynamic>[];

        return list
            .map((e) {
          if (e is String) return e;
          final m = Map<String, dynamic>.from(e as Map);
          return (m['text'] ?? '').toString();
        })
            .where((t) => t.trim().isNotEmpty)
            .toList();
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

  @override
  Future<Either<NetworkFailure, NetworkSuccess<CalendarEvent>>> updateEvent({
    required String eventId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch<CalendarEvent>(
      ApiConstants.events.byId(eventId),
      data: body,
      fromJsonT: (json) {
        // Sometimes json may be {success,message,data:{...}}
        // Sometimes it may already be the data object.
        dynamic raw = json;
        if (raw is Map && raw['data'] != null) raw = raw['data'];
        return CalendarEvent.fromApi(Map<String, dynamic>.from(raw as Map));
      },
    );
  }




}
