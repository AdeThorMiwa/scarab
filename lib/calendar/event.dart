import 'package:googleapis/calendar/v3.dart' as google_calender;

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final bool isFreeTime;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> allowedApps;

  const CalendarEvent(
    this.id, {
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.allowedApps,
    this.isFreeTime = true,
  });

  factory CalendarEvent.fromGoogleEvent(google_calender.Event event) {
    var id = event.id;
    var startTime = event.start?.dateTime;
    var endTime = event.end?.dateTime;
    var privateProperties = event.extendedProperties?.private ?? {};
    var isFreeTime =
        bool.tryParse(privateProperties["isFreeTime"] ?? "false") ?? false;
    List<String> allowedApps = (privateProperties["allowedApps"] ?? "").split(
      ",",
    );

    if (id == null || startTime == null || endTime == null) {
      throw Exception("");
    }

    return CalendarEvent(
      id,
      title: event.summary ?? "",
      description: event.description ?? "",
      startTime: startTime,
      endTime: endTime,
      isFreeTime: isFreeTime,
      allowedApps: allowedApps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'allowedApps': allowedApps,
      'isFreeTime': isFreeTime,
    };
  }
}
