import 'dart:isolate';
import 'dart:ui';

import 'package:scarab/events/event.dart';

class AppEventBus {
  static const String _portName = 'app_event_bus';

  static Stream<AppEvent> initHub() {
    final receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(receivePort.sendPort, _portName);

    return receivePort.asBroadcastStream().map((message) {
      return AppEvent.fromJson(message as Map<String, dynamic>);
    });
  }

  static void publish(AppEvent event) {
    final SendPort? hubPort = IsolateNameServer.lookupPortByName(_portName);
    if (hubPort != null) {
      hubPort.send(event.toJson());
    } else {
      // TODO: If UI is dead, might want to log this to disk
      print("Bus Offline: Event ${event.runtimeType} saved to queue.");
    }
  }
}
