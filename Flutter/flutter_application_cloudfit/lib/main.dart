import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/reward_screen.dart';

void main() {
  runApp(const CloudFitApp());
}

class CloudFitApp extends StatelessWidget {
  const CloudFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloudFit',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        fontFamily: 'Roboto', 
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/exercise': (context) => const ExerciseScreen(),
        '/reward': (context) => const RewardScreen(),
      },
    );
  }
}