import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/presentation/screens/alerts_screen.dart';
import '../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../features/analytics/presentation/screens/comparative_analytics_screen.dart';
import '../features/analytics/presentation/screens/predictive_analytics_screen.dart';
import '../features/analytics/presentation/screens/scheduled_reports_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/profile_settings_screen.dart';
import '../features/dashboard/presentation/screens/settings_screen.dart';
import '../features/debug/presentation/screens/debug_screen.dart';
import '../features/insurance/presentation/screens/insurance_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/milk_collection/presentation/screens/all_deliveries_screen.dart';
import '../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../features/entrance_fee/domain/entities/farmer_payment_status.dart';
import '../features/entrance_fee/presentation/screens/entrance_fee_list_screen.dart';
import '../features/entrance_fee/presentation/screens/record_entrance_fee_screen.dart';
import '../features/expenses/presentation/screens/add_expense_screen.dart';
import '../features/expenses/presentation/screens/expenses_list_screen.dart';
import '../features/milk_inventory/presentation/screens/milk_inventory_screen.dart';
import '../features/milk_sales/presentation/screens/record_milk_sale_screen.dart';
import '../features/off_takers/presentation/screens/create_off_taker_screen.dart';
import '../features/off_takers/presentation/screens/off_takers_list_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';

/// Application router configuration using go_router
class AppRouter {
  /// Router instance
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding screen
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Login screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Forgot password screen
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main navigation (Dashboard with bottom nav)
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MainNavigationScreen(),
      ),
      
      // Secondary activities (accessed via More Menu)
      GoRoute(
        path: AppRoutes.insurance,
        builder: (context, state) => const InsuranceScreen(),
      ),
      GoRoute(
        path: AppRoutes.loans,
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const AllDeliveriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugScreen(),
      ),
      
      // Off-takers routes
      GoRoute(
        path: AppRoutes.offTakers,
        builder: (context, state) => const OffTakersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createOffTaker,
        builder: (context, state) => const CreateOffTakerScreen(),
      ),
      
      // Expenses routes
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const ExpensesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        builder: (context, state) => const AddExpenseScreen(),
      ),
      
      // Entrance fee routes
      GoRoute(
        path: AppRoutes.entranceFee,
        builder: (context, state) => const EntranceFeeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordEntranceFee,
        builder: (context, state) {
          final farmerStatus = state.extra as FarmerPaymentStatus;
          return RecordEntranceFeeScreen(farmerStatus: farmerStatus);
        },
      ),
      
      // Milk inventory and sales routes
      GoRoute(
        path: AppRoutes.milkInventory,
        builder: (context, state) => const MilkInventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordMilkSale,
        builder: (context, state) => const RecordMilkSaleScreen(),
      ),
      
      // Analytics routes
      GoRoute(
        path: AppRoutes.analyticsDashboard,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.comparativeAnalytics,
        builder: (context, state) => const ComparativeAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.predictiveAnalytics,
        builder: (context, state) => const PredictiveAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.alerts,
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledReports,
        builder: (context, state) => const ScheduledReportsScreen(),
      ),
      // Note: ReportPreviewScreen requires report and filter objects
      // It should be navigated to programmatically with Navigator.push
      // rather than through named routes
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
  
  // Private constructor to prevent instantiation
  AppRouter._();
}

/// Route names for navigation
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String farmerList = '/farmers';
  static const String farmerDetail = '/farmers/:id';
  static const String farmerRegister = '/farmers/register';
  static const String cattleList = '/cattle';
  static const String cattleDetail = '/cattle/:id';
  static const String cattleRegister = '/cattle/register';
  static const String milkCollection = '/milk-collection';
  
  // Secondary activities (accessed via More Menu)
  static const String insurance = '/insurance';
  static const String loans = '/loans';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Off-takers routes
  static const String offTakers = '/off-takers';
  static const String createOffTaker = '/off-takers/create';
  
  // Expenses routes
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  
  // Entrance fee routes
  static const String entranceFee = '/entrance-fee';
  static const String recordEntranceFee = '/entrance-fee/record';
  
  // Milk inventory and sales routes
  static const String milkInventory = '/milk-inventory';
  static const String recordMilkSale = '/milk-sale/record';
  
  // Analytics routes
  static const String analyticsDashboard = '/analytics';
  static const String comparativeAnalytics = '/analytics/comparative';
  static const String predictiveAnalytics = '/analytics/predictive';
  static const String alerts = '/analytics/alerts';
  static const String scheduledReports = '/analytics/scheduled-reports';
  
  // Private constructor to prevent instantiation
  AppRoutes._();
}
