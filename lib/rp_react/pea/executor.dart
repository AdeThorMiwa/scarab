import 'dart:convert';

import 'package:scarab/rp_react/llm/provider.dart';
import 'package:scarab/rp_react/models.dart';
import 'package:scarab/tools/tool.dart';

/// The Proxy-Execution Agent (PEA).
///
/// Stateless executor that receives a single concrete sub-step and carries it
/// out using available tools via a ReAct loop (Think → Act → Observe → repeat).
///
/// Has NO conversation history. Each call is independent.
class ProxyExecutor {
  final LLMProvider _llm;
  final int _maxIterations;

  ProxyExecutor({required LLMProvider llm, int maxIterations = 10})
    : _llm = llm,
      _maxIterations = maxIterations;

  /// Execute a single sub-step using the provided tools.
  ///
  /// [instruction] — a concrete, self-contained instruction from the RPA.
  /// [tools] — tools available for this execution.
  /// [contextPrompt] — skill-specific instructions for the executor.
  Future<ExecutionResult> execute({
    required String instruction,
    required List<Tool> tools,
    required String contextPrompt,
  }) async {
    final systemPrompt =
        '''You are a tool executor. Your job is to carry out the given instruction by calling the available tools.

$contextPrompt

Execute the instruction precisely. When you have the final result, respond with plain text summarizing the outcome. Do not call tools unnecessarily.''';

    final history = <LLMMessage>[];
    var currentMessage = 'Instruction: $instruction';

    for (var i = 0; i < _maxIterations; i++) {
      final response = await _llm.chat(
        systemPrompt: systemPrompt,
        history: history,
        message: currentMessage,
        tools: tools,
      );

      if (response.isText) {
        // Done — the executor produced a final text result
        return ExecutionResult(output: response.text!, success: true);
      }

      if (response.isToolCall) {
        final toolCall = response.toolCall!;

        // Find and execute the tool
        final tool = tools.where((t) => t.name == toolCall.name).firstOrNull;

        if (tool == null) {
          // Tool not found — feed error back and let it retry
          history.add(LLMMessage.user(currentMessage));
          history.add(LLMMessage.assistant('Calling tool: ${toolCall.name}'));
          currentMessage =
              'Error: Tool "${toolCall.name}" not found. Available tools: ${tools.map((t) => t.name).join(", ")}';
          continue;
        }

        late String resultStr;
        try {
          final result = await tool.execute(toolCall.args);
          resultStr = jsonEncode({'result': result});
        } catch (e) {
          resultStr = jsonEncode({'error': e.toString()});
        }

        // Add the exchange to history and feed the result back
        history.add(LLMMessage.user(currentMessage));
        history.add(
          LLMMessage.assistant(
            'Calling tool: ${toolCall.name}(${jsonEncode(toolCall.args)})',
          ),
        );
        currentMessage = 'Tool result for ${toolCall.name}: $resultStr';
      }
    }

    // Max iterations reached
    return ExecutionResult(
      output: 'Execution stopped: reached maximum iterations ($_maxIterations)',
      success: false,
    );
  }
}
