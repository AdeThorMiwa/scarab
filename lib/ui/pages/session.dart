import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scarab/models/calendar.dart';
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/services/waker.dart';
import 'package:scarab/ui/state/scarab.dart';
import 'package:scarab/utils/consts.dart';

class CreateSessionPage extends ConsumerStatefulWidget {
  const CreateSessionPage({super.key});

  @override
  ConsumerState<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends ConsumerState<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();

  // Input States
  String _title = "";
  String _description = "";
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  final List<String> _selectedAppIds = [];
  bool _isLoading = false;

  // Helper to pick time
  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final newDate = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = newDate;
        } else {
          _endTime = newDate;
        }
      });
    }
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    var req = AddEventToCalendarRequest(
      title: _title,
      description: _description,
      startTime: _startTime,
      endTime: _endTime,
      allowedApps: _selectedAppIds,
      isFocusSession: true,
    );

    await CalendarService.addEventToCalendar(req, calendarId: calendarId);

    await WakerService.wake(delayUntil: Duration(seconds: 1));
  }

  void onSubmit() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() => _isLoading = true);

    try {
      final navigator = Navigator.of(context);
      await _saveSession();
      navigator.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save session: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, // Looks more like a toast
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceApps = ref.watch(deviceAppsProvider).value ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text("New Focus Session")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Title & Description
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Session Title",
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => _title = v!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Description"),
                    onSaved: (v) => _description = v ?? "",
                  ),
                  const SizedBox(height: 24),

                  // Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Start"),
                          subtitle: Text(DateFormat('jm').format(_startTime)),
                          onTap: () => _pickTime(true),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("End"),
                          subtitle: Text(DateFormat('jm').format(_endTime)),
                          onTap: () => _pickTime(false),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // App Selection Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Allow Apps (${_selectedAppIds.length})",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // App List
                  ...deviceApps.values.map((app) {
                    final isSelected = _selectedAppIds.contains(app.packageId);
                    return CheckboxListTile(
                      title: Text(app.name),
                      subtitle: Text(
                        app.packageId,
                        style: const TextStyle(fontSize: 10),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedAppIds.add(app.packageId);
                          } else {
                            _selectedAppIds.remove(app.packageId);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  // Change color when disabled to give visual feedback
                  backgroundColor: _isLoading ? Colors.grey : null,
                ),
                // Setting onPressed to null automatically disables the button
                onPressed: _isLoading ? null : onSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("CREATE SESSION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
