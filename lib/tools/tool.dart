import 'package:firebase_ai/firebase_ai.dart' as fbz;

abstract class Tool {
  final String name;
  final String description;
  final Map<String, fbz.Schema> parameters;

  const Tool(this.name, this.description, this.parameters);

  Future<dynamic> execute(Map<String, dynamic> args);

  fbz.Tool toGeminiTool() {
    return fbz.Tool.functionDeclarations([
      fbz.FunctionDeclaration(name, description, parameters: parameters),
    ]);
  }
}
