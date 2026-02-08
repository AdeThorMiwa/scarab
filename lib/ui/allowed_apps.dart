import 'package:flutter/material.dart';
import 'package:scarab/models/device.dart';

class AllowedAppsWrap extends StatelessWidget {
  const AllowedAppsWrap({super.key, required this.apps});

  final List<DeviceApplication> apps;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Text(
        'No apps allowed.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A8F98)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: apps
          .map(
            (app) => InkWell(
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF181C21),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF3A424C),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  app.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE6E8EA),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
