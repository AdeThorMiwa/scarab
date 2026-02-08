import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/models/device.dart';
import 'package:scarab/ui/state/scarab.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/ui/allowed_apps.dart';

class SessionCard extends ConsumerWidget {
  final Session session;
  final bool isActive;

  const SessionCard({super.key, required this.session, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceApps = switch (ref.watch(deviceAppsProvider)) {
      AsyncData<Map<String, DeviceApplication>>(:final value) => value,
      _ => <String, DeviceApplication>{},
    };

    final textTheme = Theme.of(context).textTheme;
    final timeRange = _timeRangeLabel(session);
    final title = session.title;

    final List<DeviceApplication> allowedApps = session.allowedApps
        .map((packageName) => deviceApps[packageName])
        .whereType<DeviceApplication>()
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFF1E2227),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusLabel(isActive),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE6E8EA),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            timeRange,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB0B4BA),
            ),
          ),
          const SizedBox(height: 8),
          AllowedAppsWrap(appCount: allowedApps.length),
        ],
      ),
    );
  }

  String _statusLabel(bool isActive) {
    if (isActive) {
      return 'Locked: Active session';
    }
    return 'Coming next';
  }

  String _timeRangeLabel(Session session) {
    var start = _formatTime(session.start);
    var end = _formatTime(session.end);
    return '$start - $end';
  }

  String _formatTime(DateTime time) {
    var meridiemHour = time.toLocal().hour % 12;
    if (meridiemHour == 0) {
      meridiemHour = 12;
    }

    var hour = meridiemHour.toString().padLeft(2, '0');
    var minute = time.minute.toString().padLeft(2, '0');
    var amPm = time.toLocal().hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
