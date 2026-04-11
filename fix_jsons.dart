import 'dart:convert';
import 'dart:io';

void main() async {
  final assetsDir = Directory('c:/la-previa/assets');
  final entities = assetsDir.listSync(recursive: false);

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.json')) {
      final fileName = entity.path.split(Platform.pathSeparator).last;
      bool isEvent = fileName.startsWith('events');
      bool isQuestion = fileName.startsWith('questions') && !fileName.contains('_en');
      bool modified = false;
      
      final content = await entity.readAsString();
      Map<String, dynamic> data;
      try {
        data = jsonDecode(content);
      } catch (e) {
        continue;
      }

      if (isEvent && data.containsKey('events')) {
        final events = data['events'] as List<dynamic>;
        for (var event in events) {
          if (event is Map && event.containsKey('template')) {
            String template = event['template'];
            String newTemplate = template.replaceFirst(RegExp(r'^(EVENTO:\s*|EVENT:\s*)'), '');
            if (newTemplate != template) {
              event['template'] = newTemplate;
              modified = true;
            }
          }
          if (event is Map) {
            String title = event['title'] ?? '';
            if (title.contains('Tragos Dobles') || title.contains('Double Drinks')) {
              if (event.containsKey('variables') && event['variables'].containsKey('MULTIPLIER')) {
                List<dynamic> multiplier = event['variables']['MULTIPLIER'];
                if (multiplier.length != 1 || multiplier[0] != "2") {
                  event['variables']['MULTIPLIER'] = ["2"];
                  modified = true;
                }
              }
            }
          }
        }
      }

      if (isQuestion && data.containsKey('questions')) {
        final questions = data['questions'] as List<dynamic>;
        for (var q in questions) {
          if (q is Map && q.containsKey('text')) {
            String text = q['text'];
            String newText = text.replaceAll(RegExp(r'\bshots\b', caseSensitive: false), 'chupitos');
            newText = newText.replaceAll(RegExp(r'\bshot\b', caseSensitive: false), 'chupito');
            if (newText != text) {
              q['text'] = newText;
              modified = true;
            }
          }
        }
      }

      if (modified) {
        // Formatter config isn't needed, standard encode with spaces
        final JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        await entity.writeAsString(encoder.convert(data));
      }
    }
  }
}
