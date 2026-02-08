import 'package:flutter/material.dart';

class AllowedAppsWrap extends StatelessWidget {
  const AllowedAppsWrap({super.key, required this.appCount});

  final int appCount;

  @override
  Widget build(BuildContext context) {
    return Text(
      textLabel,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A8F98)),
    );
  }

  String get textLabel {
    if (appCount > 2) return "$appCount apps allowed";
    if (appCount == 1) return "1 app allowed";
    return "No apps allowed";
  }
}
