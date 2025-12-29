import 'package:flutter/material.dart';
import 'package:store_buy/bienvenue_screen.dart';
import 'package:store_buy/login/connect_screen.dart';
import 'package:store_buy/login/login_screen.dart';
import 'package:store_buy/screen_client/accueil_screen.dart';
import 'package:store_buy/screen_client/panier_screen.dart';
import 'package:store_buy/screen_client/message_screen.dart';
import 'package:store_buy/screen_vendeur/homescreen.dart';
import 'package:store_buy/screen_vendeur/dashboard_screen.dart';
import 'package:store_buy/screen_vendeur/commande_screen.dart';
import 'package:store_buy/screen_vendeur/create_store_wizard.dart';
import 'package:store_buy/screen_vendeur/reviews_screen.dart';
import 'package:store_buy/screen_vendeur/employees_screen.dart';
import 'package:store_buy/screen_vendeur/stories_screen.dart';
import 'package:store_buy/screen_vendeur/store_history_screen.dart';
import 'package:store_buy/screen_vendeur/reservations_screen.dart';
import 'package:store_buy/screen_vendeur/deliveries_screen.dart';
import 'package:store_buy/screen_vendeur/message_screen.dart' show VendorMessageScreen;
import 'package:store_buy/screen_vendeur/store_settings_screen.dart';
import 'package:store_buy/screen_vendeur/support_screen.dart';
import 'package:store_buy/screen_vendeur/inventory_screen.dart';
import 'package:store_buy/onboarding_screen.dart';
import 'package:store_buy/screen_client/user_type_selection_screen.dart';
import 'package:store_buy/screen_client/join_store_screen.dart';
import 'package:store_buy/screen_client/customer_surveys_screen.dart';
import 'package:store_buy/screen_vendeur/store_photos_screen.dart';
import 'package:store_buy/screen_vendeur/surveys_screen.dart';
import 'package:store_buy/screen_vendeur/store_hours_screen.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_buy/screen_client/purchase_history_screen.dart';
import 'package:store_buy/screen_client/favorites_screen.dart';
import 'package:store_buy/screen_client/budget_screen.dart';
import 'package:store_buy/screen_client/tracking_list_screen.dart';
import 'package:store_buy/screen_client/advanced_search_screen.dart';
import 'package:store_buy/screen_client/client_support_screen.dart';
import 'package:store_buy/screen_client/live_shopping_screen.dart';
import 'package:store_buy/screen_client/settings_screen.dart';
import 'package:store_buy/login/splash_screen.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case '/connect':
        return MaterialPageRoute(builder: (_) => const ConnectScreen());
      
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case '/create-store':
        return MaterialPageRoute(builder: (_) => const CreateStoreWizard());
      
      case '/vendor-reviews':
        return MaterialPageRoute(builder: (_) => const ReviewsScreen());
      
      case '/vendor-employees':
        return MaterialPageRoute(builder: (_) => const EmployeesScreen());
      
      case '/vendor-stories':
        return MaterialPageRoute(builder: (_) => const StoriesScreen());
      
      case '/vendor-history':
        return MaterialPageRoute(builder: (_) => const StoreHistoryScreen());
      
      case '/vendor-reservations':
        return MaterialPageRoute(builder: (_) => const ReservationsScreen());
      
      case '/vendor-deliveries':
        return MaterialPageRoute(builder: (_) => const DeliveriesScreen());
      
      case '/vendor-messages':
        return MaterialPageRoute(builder: (_) => const VendorMessageScreen());
      
      case '/vendor-settings':
        return MaterialPageRoute(builder: (_) => const StoreSettingsScreen());
      
      case '/vendor-support':
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      
      case '/vendor-inventory':
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      
      case '/customer-home':
        return MaterialPageRoute(builder: (_) => const AccueilScreen());
      
      case '/vendor-home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case '/cart':
        return MaterialPageRoute(builder: (_) => const PanierScreen());
      
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessageScreen());
      
      case '/vendor-dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case '/vendor-orders':
        return MaterialPageRoute(builder: (_) => const CommandeScreen());
      
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case '/user-type-selection':
        return MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen());
      
      case '/join-store':
        return MaterialPageRoute(builder: (_) => const JoinStoreScreen());
      
      case '/customer-surveys':
        return MaterialPageRoute(builder: (_) => const CustomerSurveysScreen());
      
      case '/store-photos':
        final storeId = settings.arguments as String?;
        if (storeId != null) {
          return MaterialPageRoute(builder: (_) => StorePhotosScreen(storeId: storeId));
        }
        return MaterialPageRoute(builder: (_) => const BienvenueScreen());
      
      case '/store-surveys':
        final storeId = settings.arguments as String?;
        if (storeId != null) {
          return MaterialPageRoute(builder: (_) => SurveysScreen(storeId: storeId));
        }
        return MaterialPageRoute(builder: (_) => const BienvenueScreen());
      
      case '/store-hours':
        final storeId = settings.arguments as String?;
        if (storeId != null) {
          return MaterialPageRoute(builder: (_) => StoreHoursScreen(storeId: storeId));
        }
        return MaterialPageRoute(builder: (_) => const BienvenueScreen());
      case '/purchase-history':
        return MaterialPageRoute(builder: (_)=> const PurchaseHistoryScreen());
      case '/favorites':
        return MaterialPageRoute(builder: (_)=> const FavoritesScreen());
      case '/budget':
        return MaterialPageRoute(builder: (_)=> const BudgetScreen());
      case '/tracking-list':
        return MaterialPageRoute(builder: (_)=> const TrackingListScreen());
      case '/advanced-search':
        return MaterialPageRoute(builder: (_)=> const AdvancedSearchScreen());
      case '/client-support':
        return MaterialPageRoute(builder: (_)=> const ClientSupportScreen());
      case '/live-shopping':
        return MaterialPageRoute(builder: (_)=> const LiveShoppingScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_)=> const SettingsScreen());


        default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Future<String> getInitialRoute(BuildContext context) async {
    // Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (!onboardingCompleted) {
      return '/onboarding';
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      return '/';
    }

    // Check if user has selected their type
    final userTypeSelected = prefs.getBool('user_type_selected_${authProvider.currentUser?.userId}') ?? false;
    if (!userTypeSelected) {
      return '/user-type-selection';
    }

    if (authProvider.isVendor) {
      return '/vendor-home';
    } else {
      return '/customer-home';
    }
  }
}

