import 'dart:convert';

import 'package:scarab/rp_react/llm/provider.dart';
import 'package:scarab/rp_react/models.dart';
import 'package:scarab/skills/registry.dart';

/// The Reasoner-Planner Agent (RPA).
///
/// Holds full conversation history with the user. Responsible for:
/// - Understanding user intent
/// - Responding directly to casual/conversational messages
/// - Decomposing actionable tasks into concrete sub-steps for the PEA
/// - Reasoning about execution results and deciding next steps
class ReasonerPlanner {
  final LLMProvider _llm;
  final SkillRegistry _skillRegistry;
  final List<LLMMessage> _history = [];

  ReasonerPlanner({
    required LLMProvider llm,
    required SkillRegistry skillRegistry,
  }) : _llm = llm,
       _skillRegistry = skillRegistry;

  String get _systemPrompt =>
      '''You are Scarab, a helpful and knowledgeable assistant that lives inside a minimalist Android launcher.

Tone: Calm, concise, precise. Helpful but firm. No AI fluff.

You have two modes:

1. DIRECT RESPONSE — for casual conversation, questions, advice, brainstorming. Just answer.
2. TASK PLAN — when the user wants to DO something actionable (schedule, create focus sessions, manage calendar, plan their day).

When the user wants something actionable, you decompose it into sub-steps that an executor carries out with tools. The executor cannot ask follow-up questions — it only executes instructions and returns results.

CRITICAL — Plan iteratively, NOT all at once:
- You will receive execution results back after each batch of steps.
- If you need data before you can plan the next action (e.g., you need to see calendar events before finding free slots), emit ONLY the data-gathering steps first.
- Once you receive the data, reason about it yourself (find free slots, pick times, resolve conflicts) and THEN emit the action steps with ALL parameters filled in.
- Example flow for "find me 30 min free tomorrow":
  1. First response: steps to get calendar events for tomorrow
  2. You receive the events data back
  3. YOU analyze the events, find gaps, pick a slot
  4. Second response: step to create the session at the specific time you chose
- NEVER emit action steps (create/update/delete) in the same batch as data-gathering steps. Gather first, then act.

Each sub-step instruction must be self-contained with ALL parameters specified. The executor has no context beyond the instruction itself.

If you don't have enough information from the user to proceed, ask for clarification via a direct response.

When the user says they want to do something ("I want to work on X", "I need to study", "gym at 5pm"), default to creating focus sessions (which block distracting apps) unless they explicitly ask for a plain calendar event.

Current date and time: ${DateTime.now().toIso8601String()}

You MUST respond in valid JSON matching one of these formats:

For direct responses:
{"type": "direct", "response": "Your response text here"}

For task plans:
{"type": "plan", "skillId": "skill_id_here", "steps": [{"instruction": "Concrete step 1"}, {"instruction": "Concrete step 2"}]}

When you receive execution results, reason about the data and either:
- Return more steps based on what you learned (e.g., now that you see the calendar, create sessions in the free slots)
- Return a direct response summarizing what was accomplished

${_skillRegistry.generateManifest()}''';

  /// Process a user message. Returns either a direct response or a plan.
  Future<PlannerResponse> process(String userMessage) async {
    _history.add(LLMMessage.user(userMessage));

    final raw = await _llm.generate(
      systemPrompt: _systemPrompt,
      prompt: _buildPrompt(),
    );

    _history.add(LLMMessage.assistant(raw));

    return _parseResponse(raw);
  }

  /// Feed an execution result back so the RPA can reason about next steps.
  Future<PlannerResponse> handleResult(ExecutionResult result) async {
    final resultMsg = result.success
        ? 'Execution result: ${result.output}'
        : 'Execution failed: ${result.output}';

    _history.add(LLMMessage.user(resultMsg));

    final raw = await _llm.generate(
      systemPrompt: _systemPrompt,
      prompt: _buildPrompt(),
    );

    _history.add(LLMMessage.assistant(raw));

    return _parseResponse(raw);
  }

  /// Build the full prompt from conversation history.
  String _buildPrompt() {
    final buffer = StringBuffer();
    for (final msg in _history) {
      switch (msg.role) {
        case LLMRole.user:
          buffer.writeln('User: ${msg.content}');
        case LLMRole.assistant:
          buffer.writeln('Assistant: ${msg.content}');
        case LLMRole.tool:
          buffer.writeln('Tool (${msg.toolName}): ${msg.content}');
      }
    }
    return buffer.toString();
  }

  /// Parse the RPA's JSON response into a PlannerResponse.
  PlannerResponse _parseResponse(String raw) {
    try {
      // Extract JSON from the response (model may wrap it in markdown)
      final jsonStr = _extractJson(raw);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (json['type'] == 'direct') {
        return PlannerResponse(directResponse: json['response'] as String);
      }

      if (json['type'] == 'plan') {
        final steps = (json['steps'] as List<dynamic>)
            .map((s) => SubStep.fromJson(s as Map<String, dynamic>))
            .toList();
        return PlannerResponse(
          skillId: json['skillId'] as String?,
          subSteps: steps,
        );
      }
    } catch (e) {
      print('RPA parse error: $e, raw: $raw');
    }

    // Fallback: treat the whole response as a direct reply
    return PlannerResponse(directResponse: raw);
  }

  /// Extract JSON from a response that may be wrapped in markdown code fences.
  String _extractJson(String raw) {
    final trimmed = raw.trim();

    // Try to find JSON in code fences
    final fencePattern = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = fencePattern.firstMatch(trimmed);
    if (match != null) {
      return match.group(1)!.trim();
    }

    // Try to find raw JSON object
    final jsonStart = trimmed.indexOf('{');
    final jsonEnd = trimmed.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd > jsonStart) {
      return trimmed.substring(jsonStart, jsonEnd + 1);
    }

    return trimmed;
  }

  /// Clear conversation history.
  void reset() {
    _history.clear();
  }

  /// Current conversation history (read-only).
  List<LLMMessage> get history => List.unmodifiable(_history);
}
