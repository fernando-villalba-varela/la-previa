import 'dart:io';
import 'dart:convert';

void main() {
  final packs = {
    'bar': {
      'questions': [
        {
          "id": "bar_q1",
          "template": "El que tenga la bebida con menos hielo bebe {Y} tragos",
          "variables": {"Y": ["2", "3", "4"]},
          "categoria": "Atributos y Preferencias"
        },
        {
          "id": "bar_q2",
          "template": "Cualquiera que haya invitado alguna ronda hoy reparte {Y} tragos",
          "variables": {"Y": ["2", "3", "4"]},
          "categoria": "Atributos y Preferencias"
        },
        {
          "id": "bar_q3",
          "template": "El primero que choque vasos con la mesa bebe {Y} tragos",
          "variables": {"Y": ["1", "2"]},
          "categoria": "Velocidad"
        }
      ],
      'events': [
        {
          "id": "bar_e1",
          "title": "¡Ronda de la casa!",
          "description": "Todos beben 2 tragos en honor al camarero.",
          "categoria": "Global"
        }
      ],
      'constant': [
        {
          "id": "bar_c1",
          "title": "Ley del Meñique",
          "description": "El jugador objetivo debe beber siempre con el meñique levantado. Si olvida hacerlo, bebe 2 tragos adicionales.",
          "categoria": "Normas"
        }
      ]
    },
    'home': {
      'questions': [
        {
          "id": "home_q1",
          "template": "Cualquiera que esté en calcetines bebe {Y} tragos",
          "variables": {"Y": ["2", "3"]},
          "categoria": "Atributos y Preferencias"
        },
        {
          "id": "home_q2",
          "template": "El dueño de la casa reparte {Y} tragos por ser buen anfitrión",
          "variables": {"Y": ["3", "4", "5"]},
          "categoria": "Atributos y Preferencias"
        }
      ],
      'events': [
        {
          "id": "home_e1",
          "title": "Viaje a la nevera",
          "description": "El ultimo en ir a la cocina bebe 3 tragos.",
          "categoria": "Acción"
        }
      ],
      'constant': [
        {
          "id": "home_c1",
          "title": "El sofá es lava",
          "description": "El objetivo no puede sentarse en ningún lado en toda la partida. Si lo hace bebe castigo.",
          "categoria": "Físico"
        }
      ]
    },
    'christmas': {
      'questions': [
        {
          "id": "xmas_q1",
          "template": "El que lleve el jersey más feo según el grupo bebe {Y} tragos",
          "variables": {"Y": ["2", "3"]},
          "categoria": "Atributos y Preferencias"
        },
        {
          "id": "xmas_q2",
          "template": "El que adore cantar villancicos reparte {Y} tragos",
          "variables": {"Y": ["2", "3"]},
          "categoria": "Atributos y Preferencias"
        }
      ],
      'events': [
        {
          "id": "xmas_e1",
          "title": "¡Feliz Navidad, Madafakas!",
          "description": "Cada jugador debe darle un abrazo a quien tenga a su derecha o beber 3 tragos.",
          "categoria": "Global"
        }
      ],
      'constant': [
        {
          "id": "xmas_c1",
          "title": "Modo Elfo",
          "description": "El objetivo debe terminar cada frase diciendo 'Ho ho ho'.",
          "categoria": "Verbal"
        }
      ]
    },
    'valentine': {
      'questions': [
        {
          "id": "val_q1",
          "template": "El que haya sido peor en una cita bebe {Y} tragos",
          "variables": {"Y": ["3", "4"]},
          "categoria": "Atributos y Preferencias"
        },
        {
          "id": "val_q2",
          "template": "Cualquiera que tenga pareja en este momento reparte {Y} tragos",
          "variables": {"Y": ["2", "3"]},
          "categoria": "Atributos y Preferencias"
        }
      ],
      'events': [
        {
          "id": "val_e1",
          "title": "¡Beso de judas!",
          "description": "Da un beso al aire al jugador más guapo, el elegido reparte 3 tragos.",
          "categoria": "Global"
        }
      ],
      'constant': [
        {
          "id": "val_c1",
          "title": "Cupido borracho",
          "description": "El objetivo debe mirar fijamente a los ojos a la persona que le hable. Si mira a otro lado, bebe castigo.",
          "categoria": "Interacción"
        }
      ]
    }
  };

  void writeJson(String type, String pack, String lang, List<Map<String, dynamic>> items) {
    String filename = 'assets/${type}_${pack}';
    if (lang == 'en') {
      filename += '_en.json';
    } else {
      filename += '.json';
    }

    final data = {"templates": items};
    final jsonStr = JsonEncoder.withIndent('  ').convert(data);
    File(filename).writeAsStringSync(jsonStr);
    print('Created $filename');
  }

  packs.forEach((packName, packData) {
    writeJson('questions', packName, 'es', List<Map<String,dynamic>>.from(packData['questions'] as List));
    writeJson('events', packName, 'es', List<Map<String,dynamic>>.from(packData['events'] as List));
    writeJson('constant_challenges', packName, 'es', List<Map<String,dynamic>>.from(packData['constant'] as List));

    // For English just basic translation of same logic
    writeJson('questions', packName, 'en', List<Map<String,dynamic>>.from(packData['questions'] as List));
    writeJson('events', packName, 'en', List<Map<String,dynamic>>.from(packData['events'] as List));
    writeJson('constant_challenges', packName, 'en', List<Map<String,dynamic>>.from(packData['constant'] as List));
  });
}
