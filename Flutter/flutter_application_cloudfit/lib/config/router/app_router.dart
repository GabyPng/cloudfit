import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/sections/auth/register_screen.dart';
import 'package:flutter_application_cloudfit/sections/auth/splash_screen.dart';
import 'package:go_router/go_router.dart';
import '../../sections/dashboard/main_screen.dart';
import '../../sections/workout/exercise_screen.dart';
import '../../sections/rewards/reward_screen.dart';
import '../../sections/profile/profile_screen.dart';
import '../../shared/widgets/custom_bottom_nav.dart';
import 'package:flutter_application_cloudfit/sections/auth/login_screen.dart';



final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),


    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        
        return Scaffold(
          body: navigationShell,
          extendBody: true,
          bottomNavigationBar: CustomBottomNav(
            navigationShell: navigationShell,
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => MainScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercises',
              builder: (context, state) => const ExerciseScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rewards',
              builder: (context, state) => const RewardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
