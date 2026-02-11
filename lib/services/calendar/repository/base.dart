import 'package:scarab/services/calendar/event.dart';

abstract class CalendarEventRepository {
  String get id;

  Future<void> save(CalendarEvent event, {String calendarId});
  Future<CalendarEvent?> getById(String id, {String calendarId});
  Future<List<CalendarEvent>> getEvents({
    String calendarId,
    DateTime from,
    DateTime to,
    int size = 1,
  });

  Future<void> update(CalendarEvent event, {String calendarId});
  Future<void> delete(String eventId, {String calendarId});
}
