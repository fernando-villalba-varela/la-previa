import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('es');
  
  Locale get currentLocale => _currentLocale;
  bool get isSpanish => _currentLocale.languageCode == 'es';

  static const String _storageKey = 'selected_language';

  // Singleton pattern (optional, but using Provider so mostly for static access necessity if any)
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString(_storageKey);
    if (langCode != null) {
      _currentLocale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'es') {
      _currentLocale = const Locale('en');
    } else {
      _currentLocale = const Locale('es');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _currentLocale.languageCode);
    
    notifyListeners();
  }

  /// Simple key-value map for UI strings that are not in the JSONs
  String translate(String key, {Map<String, String>? args}) {
    Map<String, Map<String, String>> localizedValues = {
      'play_quick': {
        'es': 'PARTIDA RÁPIDA',
        'en': 'QUICK GAME',
      },
      'play_league': {
        'es': 'MODO LIGA',
        'en': 'LEAGUE MODE',
      },
      'settings': {
        'es': 'Configuración',
        'en': 'Settings',
      },
      'players': {
        'es': 'Jugadores',
        'en': 'Players',
      },
      'integrated_with': {'es': 'INTEGRADO CON', 'en': 'INTEGRATED WITH'},
      'ignite_your_night': {'es': 'ENCIENDE TU NOCHE', 'en': 'GET THE PARTY STARTED'},
      'active_challenges_title': {
        'es': 'Retos y Eventos Activos',
        'en': 'Active Challenges & Events',
      },
       'empty_active_challenges': {
        'es': 'No hay retos constantes activos',
        'en': 'No active constant challenges',
      },
      'empty_active_events': {
        'es': 'No hay eventos globales activos',
        'en': 'No active global events',
      },
      'endless_mode': {
        'es': 'Modo Endless',
        'en': 'Endless Mode',
      },
      'constant_challenges_title': {
        'es': '📋 Retos Constantes',
        'en': '📋 Constant Challenges',
      },
       'global_events_title': {
        'es': '🌐 Eventos Globales',
        'en': '🌐 Global Events',
      },
      'round': {
        'es': 'RONDA',
        'en': 'ROUND',
      },
       'tap_screen': {
        'es': 'TOCA LA PANTALLA',
        'en': 'TAP THE SCREEN',
      },
       'menu_reload_elixirs': {
        'es': 'Recarga tus elixires',
        'en': 'Refill your elixirs',
      },
      'round_100_title': {
        'es': '¡Ronda 100 Completada!',
        'en': 'Round 100 Completed!',
      },
      'round_100_content': {
        'es': 'Habéis sobrevivido a la previa, ¿Queréis continuar en el MODO ENDLESS?\n\nLa dificultad aumentará cada 25 rondas (+1 trago permanente).',
        'en': 'You survived the pre-game, do you want to continue in ENDLESS MODE?\n\nDifficulty will increase every 25 rounds (+1 permanent drink).',
      },
      'end_here': {
        'es': 'Terminar aquí',
        'en': 'End here',
      },
      'continue': {
        'es': '¡Continuar!',
        'en': 'Continue!',
      },
      'drinks_per_endless': {
        'es': 'tragos en todas las cartas',
        'en': 'drinks on all cards',
      },
      'endless_modifier': {
        'es': '(+{extra} tragos por endless)',
        'en': '(+{extra} drinks for endless)',
      },
      'level': {
        'es': 'Nivel',
        'en': 'Level',
      },
      'players_title': {
        'es': 'JUGADORES',
        'en': 'PLAYERS',
      },
      'add_player_hint': {
        'es': 'Añadir jugador...',
        'en': 'Add player...',
      },
      'add_button': {
        'es': 'Añadir',
        'en': 'Add',
      },
      'start_playing_button': {
        'es': '¡EMPEZAR A JUGAR!',
        'en': 'START PLAYING!',
      },
      'lets_drink_button': {
        'es': '¡A BEBER!',
        'en': "LET'S DRINK!",
      },
      'privacy_button': {
        'es': 'Privacidad',
        'en': 'Privacy',
      },
      'leagues_title': {
        'es': 'LIGAS',
        'en': 'LEAGUES',
      },
      'create_new_league_title': {
        'es': 'Crear nueva liga',
        'en': 'Create new league',
      },
      'league_name_label': {
        'es': 'Nombre de la liga',
        'en': 'League name',
      },
      'cancel': {
        'es': 'Cancelar',
        'en': 'Cancel',
      },
      'accept': {
        'es': 'Aceptar',
        'en': 'Accept',
      },
      // League Details
      'scoreboard_tab': {'es': 'Clasificación', 'en': 'Scoreboard'},
      'players_tab': {'es': 'Jugadores', 'en': 'Players'},
      'play_tab': {'es': 'Jugar', 'en': 'Play'},
      'custom_questions_tab': {'es': 'Preguntas', 'en': 'Custom Qs'},
      'packs_tab': {'es': 'Packs', 'en': 'Packs'},
      'pack_classic': {'es': 'Clásico', 'en': 'Classic'},
      'pack_classic_desc': {'es': 'Desafíos normales y reglas básicas', 'en': 'Standard challenges and basic rules'},
      'pack_bar': {'es': 'En el bar', 'en': 'At the bar'},
      'pack_bar_desc': {'es': 'Retos para jugar en un bar', 'en': 'Challenges to play at a bar'},
      'pack_home': {'es': 'En casa', 'en': 'At home'},
      'pack_home_desc': {'es': 'Retos para jugar en casa', 'en': 'Challenges to play at home'},
      'pack_christmas': {'es': 'Navidad', 'en': 'Christmas'},
      'pack_christmas_desc': {'es': 'Desafíos temáticos festivos', 'en': 'Festive themed challenges'},
      'pack_valentine': {'es': 'San Valentín', 'en': 'Valentine\'s Day'},
      'pack_valentine_desc': {'es': 'Retos románticos y en pareja', 'en': 'Couple and romantic challenges'},
      'stats_mvdp': {'es': 'MVDP', 'en': 'MVDP'},
      'stats_drinks': {'es': 'Tragos', 'en': 'Drinks'},
      'stats_ratita': {'es': 'Ratita', 'en': 'Party Pooper'},
      'stats_matches': {'es': 'Partidas', 'en': 'Matches'},

      // League Rules Modal
      'league_rules_btn': {'es': 'Reglas', 'en': 'Rules'},
      'import_league_btn': {'es': 'Importar', 'en': 'Import'},

      // Import / Export Liga
      'share_import_title': {'es': 'IMPORTAR LIGA', 'en': 'IMPORT LEAGUE'},
      'share_import_subtitle': {'es': 'Introduce el código que te envió tu amigo', 'en': 'Enter the code your friend sent you'},
      'share_code_6_title': {'es': 'Código de 6 dígitos', 'en': '6-digit code'},
      'share_code_6_subtitle': {'es': 'Requiere conexión a internet', 'en': 'Requires internet connection'},
      'share_code_6_hint': {'es': 'Escribe el código que te envió tu amigo:', 'en': 'Enter the code your friend sent you:'},
      'share_scan_qr_title': {'es': 'Escanear QR', 'en': 'Scan QR'},
      'share_scan_qr_subtitle': {'es': 'Usa tu cámara para escanear', 'en': 'Use your camera to scan'},
      'share_league_title': {'es': 'COMPARTIR LIGA', 'en': 'SHARE LEAGUE'},
      'share_generate_code': {'es': 'Generar código de 6 dígitos', 'en': 'Generate 6-digit code'},
      'share_scan_to_import': {'es': 'ESCANEA PARA IMPORTAR', 'en': 'SCAN TO IMPORT'},
      'share_qr_too_big': {'es': 'Esta liga es demasiado grande para un código QR.', 'en': 'This league is too large for a QR code.'},
      'share_qr_use_code': {'es': 'Por favor, usa la opción de "Código de 6 dígitos" para compartir.', 'en': 'Please use the "6-digit code" option to share.'},
      'share_qr_error': {'es': 'Error al generar QR.\nUsa el código de 6 dígitos.', 'en': 'Error generating QR.\nUse the 6-digit code.'},
      'share_code_generated_title': {'es': 'CÓDIGO GENERADO', 'en': 'CODE GENERATED'},
      'share_code_generated_subtitle': {'es': 'Dale este código a tus amigos:', 'en': 'Share this code with your friends:'},
      'share_code_valid': {'es': 'Válido por tiempo limitado', 'en': 'Valid for a limited time'},
      'share_btn': {'es': 'COMPARTIR', 'en': 'SHARE'},
      'close_btn': {'es': 'CERRAR', 'en': 'CLOSE'},
      'cancel_btn': {'es': 'Cancelar', 'en': 'Cancel'},
      'import_btn': {'es': 'IMPORTAR', 'en': 'IMPORT'},
      'share_success': {'es': '¡Liga importada con éxito!', 'en': 'League imported successfully!'},
      'share_error_title': {'es': 'Error al importar', 'en': 'Import error'},
      'share_not_found': {'es': 'No se encontró ninguna liga con ese código.', 'en': 'No league found with that code.'},
      'share_firebase_error': {'es': 'Error al conectar con Firebase. ¿Has configurado los archivos google-services.json?', 'en': 'Error connecting to Firebase. Have you configured the google-services.json files?'},
      'league_rules_title': {'es': 'Cómo funciona el Modo Liga', 'en': 'How League Mode Works'},
      'league_rules_s1_title': {'es': 'Jugadores', 'en': 'Players'},
      'league_rules_s1_body': {'es': 'Añade jugadores con avatar o foto personalizada. Cada jugador puede crear sus propias preguntas en la sección "Preguntas" de la liga.', 'en': 'Add players with an avatar or custom photo. Each player can create their own questions in the league\'s "Questions" section.'},
      'league_rules_s2_title': {'es': 'Cómo jugar', 'en': 'How to Play'},
      'league_rules_s2_body': {'es': 'En la pestaña "Jugar", pulsa sobre los packs de preguntas y los jugadores para seleccionarlos (mínimo 2). Cuando estés listo, pulsa Jugar.', 'en': 'In the "Play" tab, tap on question packs and players to select them (minimum 2). When ready, tap Play.'},
      'league_rules_s3_title': {'es': 'Conteo de tragos', 'en': 'Drink Tracking'},
      'league_rules_s3_body': {'es': 'La app registra los tragos que asigna directamente: cuando una pregunta dice "bebe X tragos" o cuando se selecciona a un jugador. Los repartos entre jugadores NO se contabilizan.', 'en': 'The app tracks drinks it assigns directly: when a question says "drink X shots" or when a player is selected. Drinks distributed between players do NOT count.'},
      'league_rules_s4_title': {'es': 'MVDP — Ganador de partida', 'en': 'MVDP — Match Winner'},
      'league_rules_s4_body': {'es': 'El jugador que más tragos acumule gana el título MVDP y recibe +3 puntos en la clasificación.', 'en': 'The player who drinks the most earns the MVDP title and receives +3 points in the scoreboard.'},
      'league_rules_s5_title': {'es': 'Ratita — El que menos bebe', 'en': 'Party Pooper — Least drinks'},
      'league_rules_s5_body': {'es': 'El jugador con menos tragos se lleva la ratita 🐭 y pierde 3 puntos. Nadie quiere ser la ratita.', 'en': 'The player with the fewest drinks gets the Party Pooper 💩 title and loses 3 points. Nobody wants to be the Party Pooper.'},
      'league_rules_s6_title': {'es': 'Empates', 'en': 'Ties'},
      'league_rules_s6_body': {'es': 'Si hay empate al ganar o perder, una ruleta decide quién se lleva el título. El duende de la suerte tiene la última palabra.', 'en': 'If there is a tie, a spin decides who gets the title. The luck goblin has the final say.'},
      'league_rules_s7_title': {'es': 'Resto de jugadores', 'en': 'Other Players'},
      'league_rules_s7_body': {'es': 'Los jugadores que no hayan ganado ni perdido (ni MVDP ni ratita) reciben +1 punto por participar en la partida.', 'en': 'Players who neither win nor lose (no MVDP, no Party Pooper) receive +1 point for participating in the match.'},
      'league_rules_s8_title': {'es': 'Clasificación', 'en': 'Scoreboard'},
      'league_rules_s8_body': {'es': 'Consulta puntos, tragos, MVDPs, ratitas y partidas jugadas en la pestaña "Clasificación" de tu liga.', 'en': 'Check points, drinks, MVDPs, Party Poopers and matches played in the "Scoreboard" tab of your league.'},

      // League Game
      'exit_game_title': {'es': '¿Salir del juego?', 'en': 'Exit game?'},
      'exit_game_confirmation': {'es': '¿Estás seguro de que quieres salir? Se perderá el progreso del juego.', 'en': 'Are you sure you want to exit? Game progress will be lost.'},
      'exit': {'es': 'Salir', 'en': 'Exit'},
      'round_label': {'es': 'RONDA', 'en': 'ROUND'},
      
      // Game Results
      'game_over_title': {'es': '¡Juego Terminado!', 'en': 'Game Over!'},
      'rounds_completed_text': {'es': 'Se han completado', 'en': 'Completed'}, // handled with interpolation
      'rounds': {'es': 'rondas', 'en': 'rounds'},
      'mvp_title': {'es': '🏆 MVDP', 'en': '🏆 MVDP'},
      'rat_title': {'es': '🐭 Ratita', 'en': '🐭 Party Pooper'},
      'drinks_count_suffix': {'es': 'tragos', 'en': 'drinks'},
      'game_statistics_title': {'es': 'Estadísticas del Juego', 'en': 'Game Statistics'},
      'save_and_return_button': {'es': 'Guardar y Volver', 'en': 'Save and Return'},
      'rating_hint': {'es': '¿Qué te parece la pregunta? ¡Valórala abajo!', 'en': 'Like the question? Rate it below!'},
      'breaking_news_intro': {'es': ' -> El duende con un litte boy en la mano anuncia lo siguiente:', 'en': ' -> The goblin holding a little boy announces:'},
      
      // Tiebreaker
      'tiebreaker_question_title': {'es': '⚖️ El duende va a hablar', 'en': '⚖️ The Goblin Speaks'},
      'tiebreaker_mvp_title': {'es': 'Desempate MVDP', 'en': 'MVDP Tiebreaker'},
      'tiebreaker_ratita_title': {'es': 'Desempate Ratita', 'en': 'Party Pooper Tiebreaker'},
      'tiebreaker_question_subtitle': {'es': 'Hay empate en quien cumple la condición\n¡El duende te ayudará a elegir!', 'en': 'There is a tie!\nThe goblin will help you choose!'},
      'tiebreaker_mvp_subtitle_1': {'es': 'Hay varios jugones empatados con', 'en': 'Several players tied with'},
      'tiebreaker_mvp_subtitle_2': {'es': 'tragos\n (Solo puede haber un', 'en': 'drinks\n (There can be only one'},
      'mvp_highlight': {'es': 'puto amo', 'en': 'GOAT'},
      'tiebreaker_ratita_subtitle_1': {'es': 'Manda huevos que hayais bebido', 'en': 'Unbelievable you drank'},
      'tiebreaker_ratita_subtitle_2': {'es': 'tragos\n (', 'en': 'drinks\n ('},
      'ratita_highlight': {'es': 'sois escoria', 'en': 'you are scum'},
      'spin_hint': {'es': 'Solo el Little Boy sabe tu destino...', 'en': 'Only the Little Boy knows your fate...'},
      'spinning_text': {'es': '¡Girando...!', 'en': 'Spinning...!'},
      'elf_chooses': {
        'es': '⚖️ EL DUENDE HA HABLADO',
        'en': '⚖️ THE GOBLIN HAS SPOKEN',
      },
      'mvp_winner_msg': {'es': '¡Se te ha caido esto! -> 👑', 'en': 'You dropped this! -> 👑'},
      'ratita_winner_msg': {'es': '¡Ratitaa🐭🐭 (JAJA)!', 'en': 'Party Pooper! 🐭🐭 (HAHA)!'},
      'question_tiebreaker_result_1': {'es': 'El duende sabe que', 'en': 'The goblin knows that'},
      'question_tiebreaker_result_2': {'es': '... ¡Así que bebete los', 'en': '... So drink the'},
      'tiebreaker_result_v2': {
        'es': 'El duende también te ha señalado a ti {name}, ¡así que bébete {drinks} {suffix}!',
        'en': 'The goblin also pointed at you {name}, so drink {drinks} {suffix}!',
      },
      'confirm': {'es': 'Confirmar', 'en': 'Confirm'},
      'confirm_result': {'es': 'Confirmar Resultado', 'en': 'Confirm Result'},
      
      // Avatar Selection
      'select_avatar_title': {'es': 'Seleccionar avatar para', 'en': 'Select avatar for'},
      'avatar_photo_title': {'es': 'Avatar / Foto', 'en': 'Avatar / Photo'},
      'choose_avatar_option': {'es': 'Elegir avatar creado', 'en': 'Choose created avatar'},
      'take_photo_option': {'es': 'Tomar foto', 'en': 'Take photo'},
      'remove_avatar_option': {'es': 'Quitar avatar/foto', 'en': 'Remove avatar/photo'},
      'choose_avatar_dialog_title': {'es': 'Elegir avatar', 'en': 'Choose avatar'},
      'no_avatars_found': {'es': 'No se encontraron avatars. Verifica la carpeta assets/avatars/', 'en': 'No avatars found. Check assets/avatars/ folder'},
      
      // League Empty State
      'empty_league_title': {'es': 'Aún no eres un borracho', 'en': 'You are not a drunkard yet'},
      'empty_league_subtitle': {'es': 'Pulsa "Nueva liga" para emborracharte de gloria o importa una liga de tu amigo.', 'en': 'Press "New League" to get drunk on glory or import a friend\'s league.'},
      'new_league_button': {'es': 'Nueva liga', 'en': 'New League'},
      'camera_permission_denied': {'es': 'Debes dar permiso de cámara para tomar una foto.', 'en': 'You must grant camera permission to take a photo.'},
      'select_avatar_grid_title': {'es': 'Elegir avatar para', 'en': 'Choose avatar for'},
      'delete_photo_title': {'es': 'Eliminar foto', 'en': 'Delete photo'},
      'delete_photo_content': {'es': '¿Quieres eliminar la foto de este jugador?', 'en': 'Do you want to delete this player\'s photo?'},
      'delete': {'es': 'Eliminar', 'en': 'Delete'},
      'confirm_delete_photo_content': {'es': '¿Quieres eliminar la foto de', 'en': 'Do you want to delete the photo of'},
      'confirm_delete_player_content': {'es': '¿Quieres eliminar a', 'en': 'Do you want to delete'},
      'no_players_title': {'es': 'No hay jugadores', 'en': 'No players'},
      'add_players_hint': {'es': 'Agrega jugadores desde la pestaña "Jugadores"', 'en': 'Add players from the "Players" tab'},
      'add_player_dots_hint': {'es': 'Añadir jugador...', 'en': 'Add player...'},
      'you_have_selected': {'es': 'Habéis señalado a', 'en': 'You have selected'},
      'who_meets_condition': {'es': '¿Quiénes cumplen la condición?', 'en': 'Who meets the condition?'},
      'select_players_button': {'es': 'Selecciona jugadores', 'en': 'Select players'},
      'confirm_selection': {'es': 'Confirmar', 'en': 'Confirm'},
      'god_bless_you': {'es': '¡Que dios os bendiga!', 'en': 'God bless you!'},
      'need_at_least_2': {'es': 'Necesitas al menos 2 jugadores', 'en': 'Need at least 2 players'},
      'select_at_least_2': {'es': 'Selecciona al menos 2 jugadores', 'en': 'Select at least 2 players'},
      'participants_count': {'es': 'participantes', 'en': 'participants'},
      'edit_players_title': {'es': 'Editar jugadores', 'en': 'Edit players'},
      'export_league_title': {'es': 'Exportar liga', 'en': 'Export League'},
      'copy_button': {'es': 'Copiar', 'en': 'Copy'},
      'close_button': {'es': 'Cerrar', 'en': 'Close'},
      'delete_player_title': {'es': 'Eliminar jugador', 'en': 'Delete player'},
      'confirm_delete_player_dialog_content': {'es': '¿Seguro que quieres eliminarlo?', 'en': 'Are you sure you want to delete them?'},
      'mvp_streak_message': {'es': '{name} ha ganado {count} veces seguidas! El duende te da 10 tragos a repartir mientras se rie y bebe.', 'en': '{name} has won {count} times in a row! The goblin gives you 10 drinks to distribute while laughing.'},
      'ratita_streak_message': {'es': '{name} ha perdido {count} veces seguidas. El duende se mea en tu boca y bebes 10 tragos.', 'en': '{name} has lost {count} times in a row. The goblin pees in your mouth and you drink 10 sips.'},
      'for_player': {'es': 'Para: {name}', 'en': 'For: {name}'},
      'rename_player_title': {'es': 'Renombrar jugador', 'en': 'Rename player'},
      'name_hint': {'es': 'Nombre', 'en': 'Name'},
      'save_button': {'es': 'Guardar', 'en': 'Save'},
      'done_button': {'es': 'Listo', 'en': 'Done'},
      'include_custom_questions': {'es': 'Incluir preguntas personalizadas', 'en': 'Include custom questions'},
      
      // Custom Mode - Manager
      'custom_mode_title': {'es': 'Modo personalizado', 'en': 'Custom Mode'},
      'delete_question_title': {'es': 'Eliminar pregunta', 'en': 'Delete Question'},
      'delete_question_confirm': {'es': '¿Eliminar "{text}"?', 'en': 'Delete "{text}"?'},
      'add_at_least_one_to_play': {'es': 'Añade al menos una pregunta para jugar', 'en': 'Add at least one question to play'},
      'play_now_button': {'es': 'Jugar ahora', 'en': 'Play Now'},
      'questions_count_singular': {'es': '1 pregunta', 'en': '1 question'},
      'questions_count_plural': {'es': '{count} preguntas', 'en': '{count} questions'},
      
      // Custom Mode - Empty State
      'no_questions_yet': {'es': 'Sin preguntas aún', 'en': 'No questions yet'},
      'create_your_own_hint': {'es': 'Crea tus propias preguntas y retos\npara jugar con tu grupo.', 'en': 'Create your own questions and challenges\nto play with your group.'},
      'add_first_question': {'es': 'Añadir primera pregunta', 'en': 'Add first question'},
      
      // Custom Mode - Form
      'edit_question_title': {'es': 'Editar pregunta', 'en': 'Edit Question'},
      'new_question_title': {'es': 'Nueva pregunta', 'en': 'New Question'},
      'save_question_button': {'es': 'Guardar', 'en': 'Save'},
      'question_or_challenge_label': {'es': 'Pregunta o reto', 'en': 'Question or challenge'},
      'question_hint': {'es': 'Ej: Bebe quien se haya levantado más tarde...', 'en': 'Ex: Drink who woke up the latest...'},
      'error_empty_question': {'es': 'Escribe una pregunta', 'en': 'Enter a question'},
      'error_short_question': {'es': 'La pregunta es demasiado corta', 'en': 'The question is too short'},
      'drinks_label': {'es': 'Tragos', 'en': 'Drinks'},
      'timer_label': {'es': 'Temporizador', 'en': 'Timer'},
      'timer_desc': {'es': 'Para retos con tiempo de ejecución', 'en': 'For challenges with a time limit'},
      'preview_label': {'es': 'Vista previa', 'en': 'Preview'},
      'drink_singular': {'es': 'trago', 'en': 'drink'},
      'drink_plural': {'es': 'tragos', 'en': 'drinks'},
      
      // Custom Mode - Game
      'end_of_questions_title': {'es': 'Fin de las preguntas', 'en': 'End of Questions'},
      'all_questions_played': {'es': '¡Se han jugado las {count} preguntas!', 'en': 'All {count} questions have been played!'},
      'back_to_menu': {'es': 'Volver al menú', 'en': 'Back to Menu'},
      'repeat_button': {'es': 'Repetir', 'en': 'Repeat'},
      'finish_button': {'es': 'Terminar', 'en': 'Finish'},
      'next_button': {'es': 'Siguiente', 'en': 'Next'},
      
      // Premium Screen
      'premium_title': {'es': 'PREMIUM', 'en': 'PREMIUM'},
      'premium_subtitle': {'es': 'ELIMINA ANUNCIOS Y DESBLOQUEA TODO', 'en': 'REMOVE ADS & UNLOCK EVERYTHING'},
      'premium_headline': {'es': '¡Juega sin interrupciones!', 'en': 'Play without interruptions!'},
      'premium_description': {
        'es': 'Pásate a la versión de pago para eliminar permanentemente los anuncios y tener acceso a todos los packs exclusivos.',
        'en': 'Upgrade to the paid version to permanently remove ads and get access to all exclusive packs.'
      },
      'buy_premium_button': {'es': 'COMPRAR PREMIUM', 'en': 'BUY PREMIUM'},
      'continue_with_ads': {'es': 'Continuar con anuncios', 'en': 'Continue with ads'},
      
      'view_privacy_policy': {
        'es': 'Ver Política de Privacidad',
        'en': 'View Privacy Policy',
      },
      // Disclaimer Screen
      'disclaimer_title': {'es': '¡AVISO DE SEGURIDAD!', 'en': 'SAFETY NOTICE!'},
      'disclaimer_content': {
        'es': 'Esta aplicación está destinada exclusivamente a mayores de 18 años. El equipo de La Previa no se hace responsable del mal uso de esta aplicación, incluyendo el consumo excesivo de alcohol o cualquier acto imprudente derivado del juego.',
        'en': 'This application is intended exclusively for users aged 18 and over. The La Previa team is not responsible for the misuse of this application, including excessive alcohol consumption or any imprudent acts resulting from the game.'
      },
      'disclaimer_rules_title': {'es': 'Recuerda jugar de forma segura:', 'en': 'Remember to play safely:'},
      'disclaimer_rule_1': {'es': 'Bebe de forma responsable.', 'en': 'Drink responsibly.'},
      'disclaimer_rule_2': {'es': 'Si bebes, no conduzcas.', 'en': 'Don\'t drink and drive.'},
      'disclaimer_rule_3': {'es': 'Respeta a los demás jugadores.', 'en': 'Respect other players.'},
      'disclaimer_rule_4': {'es': 'Cualquier reto es opcional.', 'en': 'All challenges are optional.'},
      'disclaimer_accept': {'es': 'ACEPTO Y ENTIENDO', 'en': 'I ACCEPT & UNDERSTAND'},

      // Pack purchase dialog
      'unlock_pack_title': {'es': 'Desbloquear {name}', 'en': 'Unlock {name}'},
      'unlock_pack_content': {'es': '¿Deseas añadir este pack a tu cuenta?', 'en': 'Do you want to add this pack to your account?'},
      'buy_button': {'es': 'Comprar', 'en': 'Buy'},

      // Letter counter overlay
      'count_occasions': {'es': 'Contar ocasiones', 'en': 'Count occasions'},
      'find_letter': {'es': 'Buscar la letra: "{letter}"', 'en': 'Find the letter: "{letter}"'},

      // Player selector overlay
      'who_most_likely': {'es': '¿Quién es más probable que...?', 'en': 'Who is most likely to...?'},
      'player_label': {'es': 'Jugador', 'en': 'Player'},
      'drinks_count_label': {'es': 'Tragos: {count}', 'en': 'Drinks: {count}'},

      // Import
      'import_success': {'es': '¡Liga importada con éxito!', 'en': 'League imported successfully!'},
      'unexpected_error': {'es': 'Ocurrió un error inesperado', 'en': 'An unexpected error occurred'},
    };

    if (localizedValues.containsKey(key)) {
      String value = localizedValues[key]?[_currentLocale.languageCode] ?? key;
      if (args != null) {
        args.forEach((k, v) {
          value = value.replaceAll('{$k}', v);
        });
      }
      return value;
    }
    return key;
  }
}

