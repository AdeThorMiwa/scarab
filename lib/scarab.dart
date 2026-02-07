import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scarab/calendar/event.dart';
import 'package:scarab/calendar/service.dart';
import 'package:scarab/models/app.dart';
import 'package:scarab/models/calendar.dart';
import 'package:scarab/models/chat_message.dart';
import 'package:scarab/services/device.dart';
import 'package:scarab/session/manager.dart';
import 'package:scarab/session/session.dart';
import 'utils/consts.dart';
part 'scarab.g.dart';

class ScarabState {
  final List<Content> history;
  final bool isThinking;
  final List<CalendarEvent> upcomingEvents;

  ScarabState({
    this.history = const [],
    this.isThinking = false,
    this.upcomingEvents = const [],
  });

  ScarabState copyWith({
    List<Content>? history,
    bool? isThinking,
    List<CalendarEvent>? upcomingEvents,
  }) {
    return ScarabState(
      history: history ?? this.history,
      isThinking: isThinking ?? this.isThinking,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}

@riverpod
class Scarab extends _$Scarab {
  late ChatSession _session;
  late GenerativeModel _model;

  @override
  ScarabState build() {
    _initializeModel();
    return ScarabState();
  }

  void _initializeModel() {
    final systemInstruction = """
    You are Scarab, a minimalist focus assistant...
    Role: You are "Scarab," the intelligent core of a minimalist Android launcher designed for deep focus and digital sovereignty. You are calm, concise, and protective of the user's time.

Tone: Helpful but firm. Avoid "AI fluff" (e.g., "As an AI language model..."). Speak with precision.

Capabilities:

Focus Sessions: You can help users start, schedule, and configure focus sessions.

App Management: You can identify apps necessary during a focus session and suggest only  them based on the user's goals.

Tool Use: You have access to tools like `createFocusSession`, `getDeviceApps`, `getCurrentDateTime`. Use them proactively when the user expresses a need for focus.

Guidelines:

When a user says they "need to work," ask how long, what work (so you can infer a good title and description) and suggest blocking known distractors (social media, etc.).

Use Markdown for lists and bolding to make stats or instructions scannable.

ALWAYS ask follow-up questions to clarify the user's goals and context before taking action. For example, if a user says "I need to work for 2 hours," you might respond with "What type of work will you be doing? This will help me suggest which apps to block and create a meaningful session title."

ALWAYS call getDeviceApps and getCurrentDateTime at the start of the conversation to get a sense of the day and time and what apps the user has, and use that information to inform your suggestions for the apps to allow during focus sessions, and also when you need to create the allowedApps list for a session.

ENSURE you only allow apps that are necessary for the user's stated goals during a focus session. When in doubt, ask the user, and keep the list as short as necessarily possible.

DO NOT guess app id, if the app the user want is not in list, let them know you couldn't find it and ask if there's a different app they want to allow.

If a tool call is required, explain briefly what you are doing (e.g., "I'm locking Instagram for the next hour. Focus well.")
  """;

    // Define your tools here (Internal Scarab commands)
    final createEventTool = FunctionDeclaration(
      'createFocusSession',
      'Call this whenever you want to create a focus session. This will block distracting apps',
      parameters: {
        'title': Schema.string(description: 'The title of the focus session'),
        'description': Schema.string(
          description: 'The description of the focus session',
        ),
        'startTime': Schema.string(
          description: 'The start time of the focus session in ISO 8601 format',
        ),
        'endTime': Schema.string(
          description: 'The end time of the focus session in ISO 8601 format',
        ),
        'allowedApps': Schema.array(
          items: Schema.string(
            description: 'The Android package name to allow',
          ),
          description: 'List of allowed app package names',
        ),
      },
    );

    final getDeviceAppsTool = FunctionDeclaration(
      'getDeviceApps',
      'Call this to get a list of all apps on the device',
      parameters: {},
    );

    final getCurrentDateTimeTool = FunctionDeclaration(
      'getCurrentDateTime',
      'Call this to get the current date and time',
      parameters: {},
    );

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      systemInstruction: Content.system(systemInstruction),
      tools: [
        Tool.functionDeclarations([createEventTool]),
        Tool.functionDeclarations([getDeviceAppsTool]),
        Tool.functionDeclarations([getCurrentDateTimeTool]),
      ],
    );

    // Start a session with empty history
    _session = _model.startChat();
  }

  Future<void> sendPrompt(String text) async {
    // 1. Update UI to "Thinking" and add user message to local state
    final userContent = Content.text(text);
    state = state.copyWith(
      isThinking: true,
      history: [...state.history, userContent],
    );

    try {
      // 2. Send message to Gemini
      // The SDK handles Tool Calls automatically if tools are provided
      var response = await _session.sendMessage(userContent);

      // tool call - gemini does not handle tool calls
      final functionCalls = response.functionCalls.toList();

      if (functionCalls.isNotEmpty) {
        for (final functionCall in functionCalls) {
          final input = functionCall.args;

          late dynamic result;
          if (functionCall.name == "getDeviceApps") {
            var apps = await DeviceService.getInstalledApps();

            print("Device apps: ${apps.map((e) => e.packageId).toList()}");

            result = {"apps": apps.map((e) => e.toMap()).toList()};
          } else if (functionCall.name == "createFocusSession") {
            print("Received tool call: ${functionCall.name} with args: $input");
            final req = AddEventToCalendarRequest(
              title: input["title"].toString(),
              description: input["description"].toString(),
              startTime: DateTime.parse(input["startTime"].toString()),
              endTime: DateTime.parse(input["endTime"].toString()),
              allowedApps: List<String>.from(
                (input["allowedApps"] as List<dynamic>?) ?? [],
              ),
              isFreeTime: input["isFreeTime"] as bool? ?? false,
            );

            print("Creating event with request: $req");

            try {
              var event = await CalendarService.addEventToCalendar(
                req,
                calendarId: calendarId,
              );

              result = {"event": event.toMap()};
            } catch (e) {
              print("Error creating calendar event: $e");
              result = {"error": e.toString()};
            }
          } else if (functionCall.name == "getCurrentDateTime") {
            result = {"currentDateTime": DateTime.now().toIso8601String()};
          } else {
            print("Unknown tool call: ${functionCall.name}");
            result = {"error": "Unknown tool call: ${functionCall.name}"};
          }

          // Send the response to the model so that it can use the result to
          // generate text for the user.
          response = await _session.sendMessage(
            Content.functionResponse(functionCall.name, result),
          );
        }
      }

      // 3. Update history with the AI response
      state = state.copyWith(
        history: _session.history.toList(),
        isThinking: false,
      );
    } catch (e) {
      state = state.copyWith(isThinking: false);
      print("Error during sendPrompt: $e");
      // Handle or rethrow error
    }
  }

  // Helper to clear chat
  void resetChat() {
    _session = _model.startChat();
    state = ScarabState();
  }

  void setUpcomingEvents(List<CalendarEvent> events) {
    print("setting upcoming events: ${events.map((e) => e.title).toList()}");
    state = state.copyWith(upcomingEvents: events);
  }
}

@riverpod
List<ChatMessage> chatMessages(Ref ref) {
  // Watch the AI state. Whenever history updates, this provider re-runs.
  final state = ref.watch(scarabProvider);

  return state.history
      .map((content) {
        // 1. Combine all text parts (Gemini responses can have multiple parts)
        final text = content.parts
            .whereType<TextPart>()
            .map((part) => part.text)
            .join('\n');

        // 2. Determine author and user status
        final isUser = content.role == 'user';

        return ChatMessage(
          author: isUser ? "You" : "Scarab",
          text: text.isEmpty
              ? "..."
              : text, // Handle empty parts (like during tool calls)
          isUser: isUser,
        );
      })
      .where((msg) => msg.text != "...")
      .toList(); // Optionally filter out internal noise
}

@riverpod
List<Session> upcomingSessions(Ref ref) {
  final state = ref.watch(scarabProvider);
  print(
    "Upcoming events in state: ${state.upcomingEvents.map((e) => e.title).toList()}",
  );
  return state.upcomingEvents.map((e) => Session.fromCalendarEvent(e)).toList();
}

final activeSessionProvider = FutureProvider<Session?>((ref) async {
  return await SessionService.getActiveSession();
});

final deviceAppsProvider = FutureProvider<Map<String, DeviceApplication>>((
  ref,
) async {
  var apps = await DeviceService.getInstalledApps();
  var map = Map.fromEntries(apps.map((app) => MapEntry(app.packageId, app)));
  return map;
});
