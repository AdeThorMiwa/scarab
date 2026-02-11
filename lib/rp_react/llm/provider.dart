import 'package:scarab/tools/tool.dart';

/// Abstract LLM provider. Swap implementations to change the underlying model.
abstract class LLMProvider {
  /// Send a message in a stateful conversation and get a response.
  /// The provider manages its own chat session internally.
  /// Returns either a text response or a tool call.
  Future<LLMResponse> chat({
    required String systemPrompt,
    required List<LLMMessage> history,
    required String message,
    List<Tool>? tools,
  });

  /// Stateless single-shot generation. No history, no tools.
  Future<String> generate({
    required String systemPrompt,
    required String prompt,
  });
}

/// A message in conversation history.
class LLMMessage {
  final LLMRole role;
  final String content;

  /// For tool-result messages: the name of the tool that produced this result.
  final String? toolName;

  const LLMMessage({required this.role, required this.content, this.toolName});

  factory LLMMessage.user(String content) =>
      LLMMessage(role: LLMRole.user, content: content);

  factory LLMMessage.assistant(String content) =>
      LLMMessage(role: LLMRole.assistant, content: content);

  factory LLMMessage.toolResult({
    required String toolName,
    required String content,
  }) => LLMMessage(role: LLMRole.tool, content: content, toolName: toolName);
}

enum LLMRole { user, assistant, tool }

/// Response from the LLM — either text or a tool call.
class LLMResponse {
  final String? text;
  final LLMToolCall? toolCall;

  bool get isToolCall => toolCall != null;
  bool get isText => text != null && !isToolCall;

  const LLMResponse({this.text, this.toolCall});

  factory LLMResponse.text(String text) => LLMResponse(text: text);

  factory LLMResponse.tool(LLMToolCall toolCall) =>
      LLMResponse(toolCall: toolCall);
}

/// A tool call requested by the LLM.
class LLMToolCall {
  final String name;
  final Map<String, dynamic> args;

  const LLMToolCall({required this.name, required this.args});
}
