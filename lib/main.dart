import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/medical_provider.dart';
import 'providers/ui_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'services/gemini_service.dart';

void main() {
  runApp(const MedigeniApp());
}

class MedigeniApp extends StatelessWidget {
  const MedigeniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => UIProvider()),
      ],
      child: Consumer<UIProvider>(
        builder: (context, uiProvider, _) {
          // Initialiser Gemini avec une clé API vide (à configurer)
          // L'utilisateur devra configurer sa clé API dans les paramètres
          if (!GeminiService.isInitialized) {
            // Pour l'instant, on laisse vide - l'utilisateur devra la configurer
            // GeminiService.initialize('YOUR_API_KEY_HERE');
          }

          return MaterialApp.router(
            title: 'Medigeni',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: uiProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.getRouter(context),
          );
        },
      ),
    );
  }
}
