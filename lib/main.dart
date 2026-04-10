import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- NUEVO: Para el soporte de fechas
import 'package:intl/intl.dart'; // <--- NUEVO: Para el soporte de fechas
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'data/services/supabase_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/vitals_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/auth/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/main_dashboard_screen.dart';

void main() async {
  // 1. Asegurar que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIALIZAR IDIOMA DE FECHAS (Corrige la pantalla roja de LocaleDataException)
  // Usamos 'es_ES' para español, o puedes usar null para el idioma del dispositivo
  await initializeDateFormatting('es', null);

  // 3. Inicializar Supabase
  try {
    await SupabaseService.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
    );
  } catch (e) {
    debugPrint('========================================');
    debugPrint('ERROR FATAL: Falló la inicialización de Supabase');
    debugPrint('Error: $e');
    debugPrint('========================================');
  }

  // 4. Configurar orientación de la pantalla
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const VitalTrackApp());
}

class VitalTrackApp extends StatelessWidget {
  const VitalTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Usamos ProxyProvider si VitalsProvider depende de AuthProvider (para las alertas)
        ChangeNotifierProxyProvider<AuthProvider, VitalsProvider>(
          create: (_) => VitalsProvider(),
          update: (_, auth, vitals) => vitals!..setAuthProvider(auth),
        ),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'VitalTrack',
            debugShowCheckedModeBanner: false,

            // Localización (Opcional pero recomendado para que todo se traduzca bien)
            locale: const Locale('es', 'ES'),

            // CONFIGURACIÓN DE TEMAS
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            home: const AppRouter(),
          );
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.showOnboarding) {
          return const OnboardingScreen();
        }
        if (authProvider.isAuthenticated) {
          return const MainDashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
