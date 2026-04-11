import 'dart:convert';
import 'dart:io';

void main() async {
  final assetsDir = Directory('c:/la-previa/assets');
  final entities = assetsDir.listSync(recursive: false);

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.json')) {
      final fileName = entity.path.split(Platform.pathSeparator).last;
      bool isEvent = fileName.startsWith('events');
      
      bool modified = false;
      
      final content = await entity.readAsString();
      Map<String, dynamic> data;
      try {
        data = jsonDecode(content);
      } catch (e) {
        continue;
      }

      if (isEvent && data.containsKey('templates')) {
        final events = data['templates'] as List<dynamic>;
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

      if (modified) {
        final JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        await entity.writeAsString(encoder.convert(data));
        print("Updated ${fileName}");
      }
    }
  }
}
