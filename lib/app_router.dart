import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/project_model.dart';
import '../models/user_model.dart';
import 'pages/actor_dashboard_page.dart';
import 'pages/agency_applicant_profile_page.dart';
import 'pages/agency_dashboard_page.dart';
import 'pages/create_project_page.dart';
import 'pages/edit_actor_profile_page.dart';
import 'pages/login_page.dart';
import 'pages/my_applications_page.dart';
import 'pages/project_applicants_page.dart';
import 'pages/project_detail_page.dart';
import 'pages/project_filter_page.dart';
import 'pages/project_list_page.dart';
import 'pages/register_page.dart';
import 'pages/splash_page.dart';
import 'providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (prev, next) => notifyListeners());
    _ref.listen(userModelProvider, (prev, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final userModel = ref.read(userModelProvider);

      if (authState.isLoading) return '/splash';

      final isAuth = authState.value != null;
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/login' || loc == '/register';

      if (!isAuth) return isLoggingIn ? null : '/login';

      if (userModel.isLoading || userModel.value == null) {
        return loc == '/splash' ? null : '/splash';
      }

      final role = userModel.value!.role;
      final targetDashboard = role == UserRole.actor
          ? '/actor-dashboard'
          : '/agency-dashboard';

      if (loc == '/splash' || isLoggingIn) return targetDashboard;

      // Role guard
      if (loc.startsWith('/actor-dashboard') && role != UserRole.actor) {
        return targetDashboard;
      }
      if (loc.startsWith('/agency-dashboard') && role != UserRole.agency) {
        return targetDashboard;
      }
      if (loc.startsWith('/project-applicants') && role != UserRole.agency) {
        return targetDashboard;
      }
      if (loc.startsWith('/agency-actor') && role != UserRole.agency) {
        return targetDashboard;
      }
      if (loc.startsWith('/create-project') && role != UserRole.agency) {
        return targetDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: '/actor-dashboard',
        builder: (context, state) => const ActorDashboardPage(),
      ),
      GoRoute(
        path: '/agency-dashboard',
        builder: (context, state) => const AgencyDashboardPage(),
      ),
      GoRoute(
        path: '/edit-actor-profile',
        builder: (context, state) => const EditActorProfilePage(),
      ),
      GoRoute(path: '/projects', builder: (context, state) => const ProjectListPage()),
      GoRoute(
        path: '/project-filters',
        builder: (context, state) => const ProjectFilterPage(),
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsPage(),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: '/project-detail/:id',
        builder: (context, state) => ProjectDetailPage(
          projectId: state.pathParameters['id'] ?? '',
          initialProject: state.extra is ProjectModel
              ? state.extra as ProjectModel
              : null,
        ),
      ),
      GoRoute(
        path: '/project-applicants/:projectId',
        builder: (context, state) => ProjectApplicantsPage(
          projectId: state.pathParameters['projectId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/agency-actor/:actorId',
        builder: (context, state) => AgencyApplicantProfilePage(
          actorId: state.pathParameters['actorId'] ?? '',
        ),
      ),
    ],
  );
});
