import 'package:scarab/tools/tool.dart';

abstract class Skill {
  /// Unique identifier used by the AI to select this skill
  String get id;

  /// Short human-readable name
  String get name;

  /// One-line description for the AI skill manifest
  String get description;

  /// Detailed instructions injected as system prompt during skill execution
  String get contextPrompt;

  /// Tools available to the AI when this skill is active
  List<Tool> get tools;
}
