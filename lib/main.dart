import 'package:flutter/material.dart';
import 'package:store_buy/navigation/app_router.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:store_buy/providers/product_provider.dart';
import 'package:store_buy/providers/language_provider.dart';
import 'package:store_buy/providers/offline_provider.dart';
import 'package:store_buy/service/notification_service.dart';
import 'package:store_buy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OfflineProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Store Self',
            locale: languageProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr', ''),
              Locale('en', ''),
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF64B5F6), // Bleu clair
                brightness: Brightness.light,
                primary: const Color(0xFF42A5F5), // Bleu moyen
                secondary: const Color(0xFF81C784), // Vert clair
                surface: Colors.white,
               // background: const Color(0xFFF5F5F5), // Gris très clair
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF64B5F6),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha:0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(
                  color: Color(0xFF212121),
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                ),
                headlineMedium: TextStyle(
                  color: Color(0xFF212121),
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
                bodyLarge: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 16,
                ),
                bodyMedium: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 14,
                ),
              ),
            ),
            initialRoute: '/',
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              // Check onboarding on first launch
              return FutureBuilder<String>(
                future: AppRouter.getInitialRoute(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final route = snapshot.data ?? '/';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (ModalRoute.of(context)?.settings.name != route) {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  });
                  return child ?? const SizedBox();
                },
              );
            },
          );
        },
      ),
    );
  }
}