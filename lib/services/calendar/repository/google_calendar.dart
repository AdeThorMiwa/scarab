import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'base.dart';
import '../event.dart';

Map<String, dynamic> decodeCreds(String jsonString) {
  final Map<String, dynamic> creds = jsonDecode(jsonString);

  // The Fix: Convert literal "\n" strings into actual newline characters
  if (creds.containsKey('private_key')) {
    creds['private_key'] = creds['private_key'].toString().replaceAll(
      r'\n',
      '\n',
    );
  }

  return creds;
}

class GoogleCalendarEventRepository implements CalendarEventRepository {
  final String allowedAppsDelimiter = ",";

  static final Map<String, dynamic> creds = decodeCreds(
    dotenv.get("GOOGLE_SERVICE_ACCOUNT_CREDENTIALS"),
  );

  // Your Service Account JSON details
  final _credentials = ServiceAccountCredentials.fromJson(creds);

  final _scopes = [CalendarApi.calendarScope];

  @override
  String get id => 'google_calender';

  /// Helper to get the authenticated client without user login
  Future<CalendarApi> _getCalendarApi() async {
    final client = await clientViaServiceAccount(_credentials, _scopes);
    return CalendarApi(client);
  }

  @override
  Future<List<CalendarEvent>> getEvents({
    String calendarId = "primary",
    DateTime? from,
    DateTime? to,
    int size = 1,
  }) async {
    final api = await _getCalendarApi();
    List<CalendarEvent> events = [];

    final calendarEvents = await api.events.list(
      calendarId,
      timeMin: from,
      timeMax: to,
      orderBy: "startTime",
      singleEvents: true,
      maxResults: size,
    );

    if (calendarEvents.items != null) {
      events = calendarEvents.items!
          .map((e) => CalendarEvent.fromGoogleEvent(e))
          .toList();
    }

    return events;
  }

  @override
  Future<void> save(
    CalendarEvent event, {
    String calendarId = 'primary',
  }) async {
    try {
      final api = await _getCalendarApi();

      // https://developers.google.com/workspace/calendar/api/v3/reference/events/insert
      var e = Event();
      e.id = event.id;
      e.summary = event.title;
      e.description = event.description;
      e.start = EventDateTime(dateTime: event.startTime);
      e.end = EventDateTime(dateTime: event.endTime);
      e.eventType = "default";
      e.colorId = "10";
      e.transparency = event.isFreeTime ? "transparent" : "opaque";
      e.extendedProperties = EventExtendedProperties(
        private: {
          "allowedApps": event.allowedApps.join(allowedAppsDelimiter),
          "isFreeTime": event.isFreeTime.toString(),
          "isFocusSession": event.isFocusSession.toString(),
        },
      );
      e.visibility = "private";

      print("Saving event to Google Calendar with details: ${e.toJson()}");

      await api.events.insert(e, calendarId, sendNotifications: false);
    } on DetailedApiRequestError catch (e) {
      print('API Error Status: ${e.status}');
      print('API Error Message: ${e.message}');
      // Print or log the full error details to identify the invalid parameter
      print('API Error Details: ${e.toString()}');
      rethrow;
    } catch (e) {
      // Handle other potential errors
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  @override
  Future<CalendarEvent?> getById(
    String eventId, {
    String calendarId = 'primary',
  }) async {
    try {
      final api = await _getCalendarApi();
      final event = await api.events.get(calendarId, eventId);
      return CalendarEvent.fromGoogleEvent(event);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> update(
    CalendarEvent event, {
    String calendarId = 'primary',
  }) async {
    try {
      final api = await _getCalendarApi();

      var e = Event();
      e.summary = event.title;
      e.description = event.description;
      e.start = EventDateTime(dateTime: event.startTime);
      e.end = EventDateTime(dateTime: event.endTime);
      e.colorId = "10";
      e.transparency = event.isFreeTime ? "transparent" : "opaque";
      e.extendedProperties = EventExtendedProperties(
        private: {
          "allowedApps": event.allowedApps.join(allowedAppsDelimiter),
          "isFreeTime": event.isFreeTime.toString(),
          "isFocusSession": event.isFocusSession.toString(),
        },
      );
      e.visibility = "private";

      await api.events.update(e, calendarId, event.id);
    } on DetailedApiRequestError catch (e) {
      print('API Error Status: ${e.status}');
      print('API Error Message: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> delete(String eventId, {String calendarId = 'primary'}) async {
    try {
      final api = await _getCalendarApi();
      await api.events.delete(calendarId, eventId);
    } on DetailedApiRequestError catch (e) {
      print('API Error Status: ${e.status}');
      print('API Error Message: ${e.message}');
      rethrow;
    }
  }
}
