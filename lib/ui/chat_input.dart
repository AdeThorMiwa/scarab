import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/models/device.dart';
import 'package:scarab/models/route.dart';
import 'package:scarab/ui/state/scarab.dart';
import 'package:scarab/utils/consts.dart';

class ChatInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  ChatInputState createState() => ChatInputState();
}

class ChatInputState extends ConsumerState<ChatInput> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isShowingSuggestions = false;
  List<Suggestion> _selectedSuggestion = [];
  List<Suggestion> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    ref.read(deviceAppsProvider);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _hideSuggestions(); // Clean up overlay on dispose
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final int slashIndex = text.lastIndexOf('/');

    // Only show suggestions if there is a '/' present
    if (slashIndex != -1) {
      final query = text.substring(slashIndex + 1).toLowerCase();
      final allSuggestions = _buildFullSuggestionList();

      setState(() {
        _filteredSuggestions = allSuggestions.where((s) {
          return s.title.toLowerCase().contains(query) ||
              (s.subText?.toLowerCase().contains(query) ?? false);
        }).toList();
      });

      if (_filteredSuggestions.isNotEmpty) {
        if (_isShowingSuggestions) {
          _overlayEntry?.markNeedsBuild();
        } else {
          _showSuggestions();
        }
      } else {
        _hideSuggestions();
      }
    } else {
      _hideSuggestions();
    }
  }

  List<Suggestion> _buildFullSuggestionList() {
    List<Suggestion> suggestions = [AllSuggestions()];

    suggestions.addAll(appRoutes.map((route) => NavigationSuggestion(route)));

    // ref.read is used here because this is an event handler/helper
    final deviceApps = ref
        .read(deviceAppsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => <String, DeviceApplication>{},
        );

    final activeSession = ref.read(activeSessionProvider).asData?.value;

    var allowedApps =
        activeSession?.allowedApps
            .map((appPackageId) => deviceApps[appPackageId])
            .whereType<DeviceApplication>()
            .toList() ??
        deviceApps.values.toList();

    suggestions.addAll(allowedApps.map((app) => AppSuggestion(app)));

    return suggestions;
  }

  void _showSuggestions() {
    if (_isShowingSuggestions) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Matches the width of the TextField automatically
        width: _layerLink.leaderSize?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          followerAnchor: Alignment.bottomLeft,
          targetAnchor: Alignment.topLeft,
          offset: const Offset(0, -8), // Floating just above the bar
          child: Material(
            elevation: 12,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF1D2228),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withAlpha(10)),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                separatorBuilder: (_, _) =>
                    Divider(color: Colors.white.withAlpha(5), height: 1),
                itemBuilder: (context, index) =>
                    _buildSuggestionItem(_filteredSuggestions[index]),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _isShowingSuggestions = true;
  }

  Widget _buildSuggestionItem(Suggestion suggestion) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        suggestion is AppSuggestion ? Icons.apps : Icons.auto_awesome,
        color: Colors.blueAccent,
        size: 18,
      ),
      title: Text(
        suggestion.title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: suggestion.subText != null
          ? Text(
              suggestion.subText!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .5),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () {
        final text = widget.controller.text;
        final selection = widget.controller.selection;

        // Find the last slash before the cursor to replace correctly
        final int slashIndex = text.lastIndexOf('/', selection.baseOffset - 1);
        if (slashIndex == -1) return;

        // Find the end of the current word
        int spaceIndex = text.indexOf(' ', slashIndex);
        if (spaceIndex == -1) spaceIndex = text.length;

        final replacement = suggestion.activationKey();
        final newText = text.replaceRange(slashIndex, spaceIndex, replacement);

        widget.controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: slashIndex + replacement.length,
          ),
        );

        setState(() {
          _selectedSuggestion = [..._selectedSuggestion, suggestion];
        });

        _hideSuggestions();
      },
    );
  }

  void _hideSuggestions() {
    if (!_isShowingSuggestions) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowingSuggestions = false;
  }

  void onSubmit(String text) {
    var trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (_selectedSuggestion.isNotEmpty) {
      for (var suggestion in _selectedSuggestion) {
        trimmedText = trimmedText.replaceFirst(suggestion.activationKey(), "");
        suggestion.onSelect(context);
      }
    }

    if (trimmedText.trim().isNotEmpty) {
      widget.onSubmitted(trimmedText);
    }

    setState(() {
      _selectedSuggestion = [];
    });
    widget.controller.clear();
    _hideSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    // CompositedTransformTarget ensures the Overlay knows where the TextField is
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ask Scarab or type / to see suggestions',
          filled: true,
          fillColor: const Color(0xFF1D2228),
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => onSubmit(widget.controller.text),
          ),
        ),
      ),
    );
  }
}

abstract class Suggestion {
  final String id;
  final String title;
  final String? subText;

  Suggestion(this.id, this.title, this.subText);

  void onSelect(BuildContext ctx);

  bool matches(String text) {
    return title.toLowerCase().contains(text.toLowerCase()) ||
        (subText != null &&
            subText!.toLowerCase().contains(text.toLowerCase()));
  }

  String activationKey() => ":$id";
}

class AppSuggestion extends Suggestion {
  final DeviceApplication app;

  AppSuggestion(this.app) : super(app.packageId, app.name, app.packageId);

  @override
  void onSelect(BuildContext _) {
    LaunchApp.openApp(androidPackageName: app.packageId);
  }

  @override
  String activationKey() => ":open:${app.packageId}";
}

class AllSuggestions extends Suggestion {
  AllSuggestions() : super('all_suggestions', 'All Suggestions', '');

  @override
  void onSelect(BuildContext _) {
    // Do nothing
  }
}

class NavigationSuggestion extends Suggestion {
  AppRoute route;

  NavigationSuggestion(this.route)
    : super(route.path, route.name, route.description);

  @override
  void onSelect(BuildContext context) {
    Navigator.pushNamed(context, route.path);
  }

  @override
  String activationKey() => ":goto:${route.path}";
}
