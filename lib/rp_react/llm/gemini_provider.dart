import 'package:firebase_ai/firebase_ai.dart' as fb;
import 'package:scarab/rp_react/llm/provider.dart';
import 'package:scarab/tools/tool.dart';

/// Gemini implementation of [LLMProvider] using Firebase AI.
class GeminiProvider implements LLMProvider {
  final String model;

  GeminiProvider({this.model = 'gemini-2.5-flash'});

  @override
  Future<LLMResponse> chat({
    required String systemPrompt,
    required List<LLMMessage> history,
    required String message,
    List<Tool>? tools,
  }) async {
    final geminiTools = tools?.map((t) => t.toGeminiTool()).toList();

    final generativeModel = fb.FirebaseAI.googleAI().generativeModel(
      model: model,
      systemInstruction: fb.Content.system(systemPrompt),
      tools: geminiTools,
    );

    // Convert our history to Gemini Content objects
    final geminiHistory = _toGeminiHistory(history);
    final chat = generativeModel.startChat(history: geminiHistory);

    final response = await chat.sendMessage(fb.Content.text(message));

    return _parseResponse(response);
  }

  @override
  Future<String> generate({
    required String systemPrompt,
    required String prompt,
  }) async {
    final generativeModel = fb.FirebaseAI.googleAI().generativeModel(
      model: model,
      systemInstruction: fb.Content.system(systemPrompt),
    );

    final response = await generativeModel.generateContent([
      fb.Content.text(prompt),
    ]);

    return response.text ?? '';
  }

  /// Convert our LLMMessage list to Gemini Content list.
  List<fb.Content> _toGeminiHistory(List<LLMMessage> history) {
    return history.map((msg) {
      switch (msg.role) {
        case LLMRole.user:
          return fb.Content('user', [fb.TextPart(msg.content)]);
        case LLMRole.assistant:
          return fb.Content('model', [fb.TextPart(msg.content)]);
        case LLMRole.tool:
          return fb.Content.functionResponse(msg.toolName ?? 'unknown', {
            'result': msg.content,
          });
      }
    }).toList();
  }

  /// Parse a Gemini response into our LLMResponse type.
  LLMResponse _parseResponse(fb.GenerateContentResponse response) {
    final functionCalls = response.functionCalls.toList();

    if (functionCalls.isNotEmpty) {
      final call = functionCalls.first;
      return LLMResponse.tool(LLMToolCall(name: call.name, args: call.args));
    }

    return LLMResponse.text(response.text ?? '');
  }
}
