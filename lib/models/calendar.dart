class AddEventToCalendarRequest {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> allowedApps;

  const AddEventToCalendarRequest({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.allowedApps,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'allowedApps': allowedApps,
    };
  }
}
