import 'package:scarab/tools/tool.dart';

class CurrentDateTimeTool extends Tool {
  CurrentDateTimeTool()
    : super(
        'get_current_date_time',
        'Call this to get the current date and time',
        {},
      );

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    return DateTime.now().toIso8601String();
  }
}
