import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/bookings_screen.dart';
import '../../features/home/presentation/profile_screen.dart';
import '../../features/home/presentation/scaffold_with_navbar.dart';
import '../../features/services/presentation/pages/service_details_page.dart';
import '../../features/services/presentation/pages/more_services_page.dart';
import '../../features/services/presentation/pages/services_by_category_page.dart';
import '../../features/home/presentation/categories_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_plans_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_bookings_page.dart';
import '../../features/admin/presentation/pages/admin_profile_page.dart';
import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/add_edit_category_page.dart';
import '../../features/categories/domain/entities/category_entity.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/admin/presentation/pages/admin_services_page.dart';
import '../../features/admin/presentation/pages/add_edit_service_page.dart';
import '../../features/services/domain/entities/service_entity.dart';

import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthStateListenable(authState),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsScreen(),
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/service/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceDetailsPage(serviceId: id);
        },
      ),
      GoRoute(
        path: '/services-by-category/:categoryName',
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return ServicesByCategoryPage(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: '/more-services',
        builder: (context, state) => const MoreServicesPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/book_service',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingPage(
            serviceId: extra['serviceId'],
            serviceName: extra['serviceName'],
            price: extra['price'],
          );
        },
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionPlansPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'users',
            builder: (context, state) => const AdminUsersPage(),
          ),
          GoRoute(
            path: 'bookings',
            builder: (context, state) => const AdminBookingsPage(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const AdminProfilePage(),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const AdminCategoriesPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditCategoryPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final category = state.extra as CategoryEntity?;
                  return AddEditCategoryPage(category: category);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const AdminServicesPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditServicePage(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final service = state.extra as ServiceEntity?;
                  return AddEditServicePage(service: service);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isAuthenticated = authState.value != null;
      final user = authState.value;
      final isLoggingIn =
          state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // Role-based redirection
      if (user?.role == UserRole.admin) {
        // If admin is at root, go to admin dashboard
        if (state.uri.path == '/') return '/admin';
        // If admin tries to go to customer pages (simple prevention, optional)
        // For now, allow admin to explore but default to /admin
      } else {
        // Customer trying to access admin
        if (state.uri.path.startsWith('/admin')) return '/';
      }

      if (isLoggingIn) {
        if (user?.role == UserRole.admin) return '/admin';
        return '/';
      }

      return null;
    },
  );
});

class _AuthStateListenable extends ChangeNotifier {
  final AsyncValue<UserEntity?> authState;

  _AuthStateListenable(this.authState);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
