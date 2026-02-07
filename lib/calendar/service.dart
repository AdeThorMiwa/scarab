import 'package:scarab/calendar/event.dart';
import 'package:scarab/calendar/repository/base.dart';
import 'package:scarab/calendar/repository/google_calendar.dart';
import 'package:scarab/models/calendar.dart';
import 'package:scarab/services/device.dart';
import 'package:collection/collection.dart';
import 'package:scarab/utils/id.dart';

class CalendarService {
  static final CalendarEventRepository _repository =
      GoogleCalendarEventRepository();

  static Future<CalendarEvent> addEventToCalendar(
    AddEventToCalendarRequest req, {
    String calendarId = "default",
  }) async {
    var deviceApps = await DeviceService.getInstalledApps();

    print("got here too");

    for (final packageId in req.allowedApps) {
      var match = deviceApps.firstWhereOrNull(
        (dApp) => dApp.packageId == packageId,
      );

      if (match == null) {
        throw Exception("Invalid appId '$packageId'");
      }
    }

    print("got here");

    var overlappingEvents = await _repository.getEvents(
      calendarId: calendarId,
      from: req.startTime,
      to: req.endTime,
    );

    print(
      "overlapping events: ${overlappingEvents.map((e) => e.toMap()).toList()}",
    );

    if (overlappingEvents.isNotEmpty) {
      throw Exception("Time unavialable");
    }

    var id = generateHexString();

    print("Creating calendar event with id: $id");

    CalendarEvent evt = CalendarEvent(
      id,
      title: "[Scarab] - ${req.title}",
      description: req.description,
      startTime: req.startTime,
      endTime: req.endTime,
      allowedApps: req.allowedApps,
      isFreeTime: req.isFreeTime,
    );

    await _repository.save(evt, calendarId: calendarId);
    return evt;
  }

  static Future<List<CalendarEvent>> getNextEvents({
    String calendarId = "default",
    int size = 1,
  }) async {
    var endOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
    );

    return await _repository.getEvents(
      calendarId: calendarId,
      from: DateTime.now().subtract(Duration(minutes: 1)),
      to: endOfDay,
      size: size,
    );
  }
}
