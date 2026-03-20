import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'core/services/database_service_v2.dart';
import 'core/services/consent_and_ad_service.dart';
import 'core/services/language_service.dart';
import 'core/services/league_storage_service.dart';
import 'core/presentation/transitions/custom_page_transitions.dart';
import 'features/league/presentation/viewmodels/league_list_viewmodel.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Servicio de almacenamiento (Inyección de Dependencias manual sencilla)
  final storageService = LeagueStorageService();

  // Crear el ViewModel inyectando el servicio y cargar las ligas guardadas
  final leagueListVM = LeagueListViewModel(storageService: storageService);
  await leagueListVM.loadLeagues();

  // Inicializar servicio de idiomas
  final languageService = LanguageService();
  await languageService.loadLanguage();

  // ANADIR: consentimiento GDPR + inicializacion AdMob
  // unawaited para no bloquear el arranque de la app
  unawaited(ConsentService().initialize());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: leagueListVM),
        ChangeNotifierProvider.value(value: languageService),
        Provider<DatabaseService>(create: (_) => DatabaseService()), // ANADIR
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Diseño base (puedes usar el tamaño de tu dispositivo de prueba)
      designSize: const Size(360, 800), // Tamaño estándar de referencia
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'La Previa',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: FadeSlidePageTransitionsBuilder(),
                TargetPlatform.iOS: FadeSlidePageTransitionsBuilder(),
                TargetPlatform.macOS: FadeSlidePageTransitionsBuilder(),
                TargetPlatform.linux: FadeSlidePageTransitionsBuilder(),
                TargetPlatform.windows: FadeSlidePageTransitionsBuilder(),
                TargetPlatform.fuchsia: FadeSlidePageTransitionsBuilder(),
              },
            ),
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}






