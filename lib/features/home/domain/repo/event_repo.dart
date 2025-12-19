import 'package:dartz/dartz.dart';
import '../../../../core/network/models/network_failure.dart';
import '../../../../core/network/models/network_success.dart';
import '../../data/models/calendar_event.dart';

abstract class EventRepo {
  Future<Either<NetworkFailure, NetworkSuccess<List<CalendarEvent>>>> listEvents({
    required String startDate, // yyyy-MM-dd
    required String endDate,   // yyyy-MM-dd
  });

  Future<Either<NetworkFailure, NetworkSuccess<CalendarEvent>>> createEvent({
    required Map<String, dynamic> body,
  });

  Future<Either<NetworkFailure, NetworkSuccess<List<String>>>> listTodos({
    required String eventId,
  });

  Future<Either<NetworkFailure, NetworkSuccess<void>>> createTodo({
    required Map<String, dynamic> body,
  });
}
