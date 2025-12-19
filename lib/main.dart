// lib/main.dart
// FINAL — WORKS FOR ADMIN + TRAINER + CLIENT — INSTANT — WITH ROUTE OBSERVER + APP CHECK DEBUG

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // ✅ ADDED
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/trainer/presentation/workout_plans_database.dart';
import 'firebase_options.dart';

/// GLOBAL ROUTE OBSERVER FOR SCREEN RELOADS
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔥 APP CHECK — DEBUG MODE (NO BILLING, SIMULATOR SAFE)
  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.debug,
  );

  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlansDatabase()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FitTrack',
            locale: languageProvider.locale,
            theme: themeProvider.currentTheme,
            themeMode: ThemeMode.system,
            navigatorObservers: [routeObserver],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (_controller.value * 0.5),
                  child: Transform.rotate(
                    angle: _controller.value * 6.28318,
                    child: const Icon(
                      Icons.fitness_center,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              "FitTrack",
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (_controller.value * 0.5),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "C",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              "Loading your fitness journey...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = 0.1 + (index * 0.2);
                    final pulseValue =
                    (_controller.value - delay).clamp(0.0, 1.0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withAlpha((pulseValue * 255).round()),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
