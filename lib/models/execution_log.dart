enum ExecutionLogType {
  plannerStart,
  plannerResult,
  stepStart,
  stepComplete,
  error,
  complete,
}

class ExecutionLogEntry {
  final DateTime timestamp;
  final ExecutionLogType type;
  final String message;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const ExecutionLogEntry({
    required this.timestamp,
    required this.type,
    required this.message,
    this.duration,
    this.metadata,
  });
}
