import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const DebateMeApp());
}

class DebateMeApp extends StatelessWidget {
  const DebateMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebateMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
