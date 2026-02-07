import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/scarab.dart';
import 'package:scarab/session/session.dart';
import 'package:scarab/ui/cards/status_card.dart';

class DailySessions extends ConsumerStatefulWidget {
  const DailySessions({super.key});

  @override
  DailySessionsState createState() => DailySessionsState();
}

class DailySessionsState extends ConsumerState<DailySessions> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var activeSession = switch (ref.watch(activeSessionProvider)) {
      AsyncData<Session?>(:final value) => value,
      _ => null,
    };

    var upcomingSessions = ref.watch(upcomingSessionsProvider);

    return SizedBox(
      // PageView needs a height constraint in a Column/Expanded
      height: 180,
      width: double.infinity,
      child: PageView(
        controller: _pageController,
        padEnds: false,
        children: [
          if (activeSession != null)
            _buildCarouselItem(
              SessionCard(session: activeSession, isActive: true),
            ),
          if (upcomingSessions.isNotEmpty)
            ...upcomingSessions.map(
              (session) => _buildCarouselItem(
                SessionCard(session: session, isActive: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(Widget card) {
    return Padding(padding: const EdgeInsets.only(right: 8.0), child: card);
  }
}
