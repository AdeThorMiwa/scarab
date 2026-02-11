/// A single concrete sub-step the RPA wants the PEA to execute.
class SubStep {
  final String instruction;
  final String? skillId;

  const SubStep({required this.instruction, this.skillId});

  factory SubStep.fromJson(Map<String, dynamic> json) {
    return SubStep(
      instruction: json['instruction'] as String,
      skillId: json['skillId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    if (skillId != null) 'skillId': skillId,
  };
}

/// Result of a PEA executing a sub-step.
class ExecutionResult {
  final String output;
  final bool success;

  const ExecutionResult({required this.output, required this.success});
}

/// What the RPA returns after reasoning about a user message.
/// Either a direct response (casual chat) or a plan of sub-steps (task).
class PlannerResponse {
  final String? directResponse;
  final List<SubStep>? subSteps;
  final String? skillId;

  bool get isDirectResponse => directResponse != null;
  bool get isPlan => subSteps != null && subSteps!.isNotEmpty;

  const PlannerResponse({this.directResponse, this.subSteps, this.skillId});
}
