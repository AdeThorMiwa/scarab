import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:scarab/services/calendar/event.dart';
import 'package:scarab/services/alarm/service.dart';
import 'package:scarab/services/session.dart';
import 'package:scarab/models/session.dart';

class DebugScreen extends StatelessWidget {
  DebugScreen({super.key});

  final session = Session.fromCalendarEvent(
    CalendarEvent(
      "test_notification_event_1",
      description: "Testing notification from Scarab",
      title: "Test Notification",
      startTime: DateTime.now().subtract(Duration(seconds: 5)),
      endTime: DateTime.now().add(Duration(minutes: 2)),
      allowedApps: [
        // "com.example.scarab",
        "com.whatsapp",
        // "com.google.android.apps.nexuslauncher",
      ],
      isFreeTime: false,
    ),
  );

  void handleClick() async {
    await SessionService.startSession(session);
  }

  void handleStopSession() async {
    await SessionService.killSession(session);
  }

  void ringAlarm() async {
    await AlarmService.ring();
  }

  void stopAlarm() async {
    await AlarmService.stop();
  }

  void showOverlay() async {
    FlutterAccessibilityService.showOverlayWindow();
  }

  void sendMessage() async {
    var response = await SessionService.sendMessageToSession(session.id, {
      "command": "log",
      "message": "This is from the enforcer",
    });

    print(response);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      /// i need a button to test notifications
      home: Scaffold(
        backgroundColor: Colors.green,
        body: SizedBox.expand(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(64),
              child: Column(
                spacing: 20.0,
                children: [
                  ElevatedButton(
                    onPressed: handleClick,
                    child: Text('Start Session'),
                  ),

                  ElevatedButton(
                    onPressed: handleStopSession,
                    child: Text('End Session'),
                  ),

                  ElevatedButton(
                    onPressed: ringAlarm,
                    child: Text('Ring alarm'),
                  ),

                  ElevatedButton(
                    onPressed: stopAlarm,
                    child: Text('Stop alarm'),
                  ),

                  ElevatedButton(
                    onPressed: showOverlay,
                    child: Text('Show overlay'),
                  ),

                  ElevatedButton(
                    onPressed: sendMessage,
                    child: Text('Send message'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
