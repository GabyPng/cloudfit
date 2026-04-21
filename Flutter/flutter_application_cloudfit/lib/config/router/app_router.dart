import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/features/coach/presentation/screens/add_client_screen.dart';
import 'package:flutter_application_cloudfit/features/coach/presentation/screens/add_exercises_screen.dart';
import 'package:flutter_application_cloudfit/features/coach/presentation/screens/client_detail_screen.dart';
import 'package:flutter_application_cloudfit/features/coach/presentation/screens/coach_main_screen.dart';
import 'package:flutter_application_cloudfit/features/coach/presentation/screens/create_routine_screen.dart';
import 'package:flutter_application_cloudfit/sections/auth/register_screen.dart';
import 'package:flutter_application_cloudfit/sections/auth/splash_screen.dart';
import 'package:flutter_application_cloudfit/sections/calendar/calendar_screen.dart';
import 'package:flutter_application_cloudfit/sections/nutrition/nutrition_screen.dart';
import 'package:flutter_application_cloudfit/sections/professionals/professional_screen.dart';
import 'package:flutter_application_cloudfit/sections/progress/progress_screen.dart';
import 'package:flutter_application_cloudfit/sections/workout/exercise_detail_screen.dart';
import 'package:flutter_application_cloudfit/sections/workout/workout_summary_screen.dart';
import 'package:flutter_application_cloudfit/sections/roles/admin_index_screen.dart';
import 'package:flutter_application_cloudfit/sections/roles/coach_index_screen.dart';
import 'package:flutter_application_cloudfit/sections/roles/nutriologo_index_screen.dart';
import 'package:go_router/go_router.dart';
import '../../sections/dashboard/main_screen.dart';
import '../../sections/workout/exercise_screen.dart';
import '../../sections/rewards/reward_screen.dart';
import '../../sections/profile/profile_screen.dart';
import '../../shared/widgets/custom_bottom_nav.dart';
import 'package:flutter_application_cloudfit/sections/auth/login_screen.dart';
import '../../core/auth_service.dart';
import '../../core/user_role.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isPublicRoute(String location) {
  return location == '/splash' ||
      location == '/login' ||
      location == '/register';
}

bool _isClienteRoute(String location) {
  return location == '/cliente' || location.startsWith('/cliente/');
}

String? _redirectByAuthAndRole(GoRouterState state) {
  final isLoggedIn = AuthService.currentUser != null;
  final location = state.matchedLocation;

  if (!isLoggedIn) {
    if (_isPublicRoute(location)) return null;
    return '/login';
  }

  final role = AuthService.currentRole;
  final home = roleHomeRoute(role);

  if (_isPublicRoute(location)) {
    return home;
  }

  if (location.startsWith('/admin') && role != UserRole.admin) {
    return home;
  }

  if (location.startsWith('/coach') && role != UserRole.coach) {
    return home;
  }

  if (location.startsWith('/nutriologo') && role != UserRole.nutriologo) {
    return home;
  }

  if (_isClienteRoute(location) && role != UserRole.cliente) {
    return home;
  }

  return null;
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) => _redirectByAuthAndRole(state),
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

    GoRoute(
      path: '/cliente/exercise-detail',
      name: ExerciseDetailScreen.name,
      builder: (context, state) => const ExerciseDetailScreen(),
    ),

    GoRoute(
      path: '/cliente/summary',
      name: WorkoutSummaryScreen.name,
      builder: (context, state) => const WorkoutSummaryScreen(),
    ),
    GoRoute(
      path: '/cliente/calendar',
      name: CalendarScreen.name,
      builder: (context, state) => const CalendarScreen(),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminIndexScreen(),
    ),
    
    GoRoute(
      path: '/nutriologo',
      builder: (context, state) => const NutriologoIndexScreen(),
    ),
    GoRoute(
      path: '/coach-home',
      name: CoachMainScreen.name,
      builder: (context, state) => const CoachMainScreen(),
    ),
    GoRoute(
      path: '/add-client',
      name: AddClientScreen.name,
      builder: (context, state) => const AddClientScreen(),
    ),
    GoRoute(
  path: '/client-detail/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ClientDetailScreen(clientId: id);
  },
),
GoRoute(
  path: '/create-routine/:clientId',
  builder: (context, state) {
    final clientId = state.pathParameters['clientId']!;
    return CreateRoutineScreen(clientId: clientId);
  },
),
GoRoute(
  path: '/add-exercises/:routineId',
  builder: (context, state) => AddExercisesScreen(routineId: state.pathParameters['routineId']!),
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
            GoRoute(
              path: '/cliente',
              builder: (context, state) => MainScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/exercises',
              builder: (context, state) => const ExerciseScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/nutrition',
              builder: (context, state) => const NutritionScreen(),
            ),
          ],
        ),
        // 4ta Rama: Progreso (Índice 3)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/rewards',
              builder: (context, state) => const RewardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cliente/professionals',
              builder: (context, state) => const ProfessionalsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
