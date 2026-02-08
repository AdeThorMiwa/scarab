import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:scarab/services/calendar/event.dart';

class Session {
  final String id;
  final String title;
  final List<String> allowedApps;
  final DateTime start;
  final DateTime end;
  final List<int> reminderOffsets = [30, 10];
  final List<Content> llmChatHistory;

  Session(
    this.id, {
    required this.title,
    required this.allowedApps,
    required this.start,
    required this.end,
    required this.llmChatHistory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'allowedApps': allowedApps, // Lists are generally JSON-serializable
      'start': start.toIso8601String(), // Convert DateTime to String
      'end': end.toIso8601String(),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates a Session object from a Map.
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      map['id'] as String,
      title: map['title'] as String,
      // Ensure the list is correctly cast as a List<String>
      allowedApps: List<String>.from(map['allowedApps'] ?? []),
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      llmChatHistory: [],
    );
  }

  factory Session.fromJson(String s) {
    return Session.fromMap(jsonDecode(s));
  }

  factory Session.fromCalendarEvent(CalendarEvent event) {
    return Session(
      event.id,
      title: event.title,
      allowedApps: event.allowedApps,
      start: event.startTime,
      end: event.endTime,
      llmChatHistory: [],
    );
  }
}
