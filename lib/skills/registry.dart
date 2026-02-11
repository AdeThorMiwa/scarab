import 'package:scarab/skills/skill.dart';
import 'package:scarab/skills/definitions/calendar.dart';
import 'package:scarab/skills/definitions/focus_session.dart';
import 'package:scarab/skills/definitions/day_planner.dart';

class SkillRegistry {
  final List<Skill> _skills;

  SkillRegistry()
    : _skills = [CalendarSkill(), FocusSessionSkill(), DayPlannerSkill()];

  List<Skill> get skills => List.unmodifiable(_skills);

  Skill? getSkillById(String id) {
    try {
      return _skills.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Generates a manifest string listing all available skills for the system prompt.
  String generateManifest() {
    final buffer = StringBuffer('Available skills:\n');
    for (final skill in _skills) {
      buffer.writeln('- ${skill.id}: ${skill.description}');
    }
    return buffer.toString();
  }
}
