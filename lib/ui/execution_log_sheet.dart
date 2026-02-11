import 'package:flutter/material.dart';
import 'package:scarab/models/execution_log.dart';

void showExecutionLogSheet(
  BuildContext context,
  List<ExecutionLogEntry> entries,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0F1113),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _ExecutionLogSheet(entries: entries),
  );
}

class _ExecutionLogSheet extends StatelessWidget {
  const _ExecutionLogSheet({required this.entries});

  final List<ExecutionLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3F47),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Execution Log',
          style: TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _LogEntryRow(entry: entries[index]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LogEntryRow extends StatelessWidget {
  const _LogEntryRow({required this.entry});

  final ExecutionLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor(entry.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
          if (entry.duration != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1E23),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(entry.duration!),
                style: const TextStyle(
                  color: Color(0xFF6A6F78),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  (IconData, Color) _iconAndColor(ExecutionLogType type) {
    return switch (type) {
      ExecutionLogType.plannerStart => (
        Icons.psychology,
        const Color(0xFF6A6F78),
      ),
      ExecutionLogType.plannerResult => (
        Icons.checklist,
        const Color(0xFF6A6F78),
      ),
      ExecutionLogType.stepStart => (Icons.play_arrow, const Color(0xFF6A6F78)),
      ExecutionLogType.stepComplete => (
        Icons.check_circle_outline,
        const Color(0xFF4CAF50),
      ),
      ExecutionLogType.error => (Icons.warning_amber, const Color(0xFFEF5350)),
      ExecutionLogType.complete => (Icons.done_all, const Color(0xFF4CAF50)),
    };
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds >= 60) {
      return '${d.inMinutes}m ${d.inSeconds % 60}s';
    }
    if (d.inMilliseconds >= 1000) {
      return '${(d.inMilliseconds / 1000).toStringAsFixed(1)}s';
    }
    return '${d.inMilliseconds}ms';
  }
}
