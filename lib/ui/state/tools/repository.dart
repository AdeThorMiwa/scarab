import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/ui/state/tools/interface.dart';

class ToolRepository {
  final List<Tool> _tools = [];

  List<Tool> get tools => List.unmodifiable(_tools);

  Tool? getToolByName(String name) {
    try {
      return _tools.firstWhere((tool) => tool.name == name);
    } catch (e) {
      return null; // Tool not found
    }
  }

  Future<fbz.GenerateContentResponse> processGeminiToolCall(
    fbz.GenerateContentResponse response,
    fbz.ChatSession chat,
  ) async {
    final functionCalls = response.functionCalls.toList();

    if (functionCalls.isNotEmpty) {
      for (final functionCall in functionCalls) {
        final tool = getToolByName(functionCall.name);
        if (tool == null) {
          print("No tool found for function call: ${functionCall.name}");
          continue;
        }

        late Map<String, dynamic> result;

        try {
          result = {"result": await tool.execute(functionCall.args)};
        } catch (e) {
          result = {"error": e.toString()};
        }

        response = await chat.sendMessage(
          fbz.Content.functionResponse(functionCall.name, result),
        );
      }
    }

    return response;
  }
}
