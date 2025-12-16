import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/push_notification_service.dart';
import 'data/models/menu_item_model.dart';
import 'data/models/local_dunamys_model.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/orders/my_orders_screen.dart';
import 'presentation/screens/orders/order_detail_screen.dart';
import 'presentation/screens/faq/faq_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/item_details/item_details_screen.dart';
import 'presentation/screens/item_category/item_category_screen.dart';
import 'presentation/screens/payment/payment_screen.dart';
import 'presentation/screens/pix_payment/pix_payment_screen.dart';
import 'presentation/screens/order_done/order_done_screen.dart';
import 'presentation/screens/feedback/feedback_screen.dart';
import 'presentation/screens/sac/sac_screen.dart';
import 'presentation/screens/maps/maps_screen.dart';
import 'presentation/screens/gallery/gallery_screen.dart';
import 'presentation/screens/gallery/local_selected_screen.dart';
// Admin screens
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/admin/admin_orders_screen.dart';
import 'presentation/screens/admin/admin_order_detail_screen.dart';
import 'presentation/screens/admin/admin_products_screen.dart';
import 'presentation/screens/admin/admin_product_form_screen.dart';
import 'presentation/screens/admin/admin_categories_screen.dart';
import 'presentation/screens/admin/admin_stock_screen.dart';
import 'presentation/screens/admin/admin_feedback_screen.dart';
import 'presentation/screens/admin/admin_faq_screen.dart';
import 'presentation/screens/admin/admin_reports_screen.dart';
import 'presentation/screens/admin/admin_media_screen.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/faq_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'data/repositories/home_repository_impl.dart';
import 'data/services/environment_service.dart';

void main() async {
  // Configura URL Strategy para web (remove # da URL)
  usePathUrlStrategy();
  
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD1pui2pXaHAwKZx4g8EgcrajUk5J69AI8",
        authDomain: "hotel-dunamys-ay9x21.firebaseapp.com",
        projectId: "hotel-dunamys-ay9x21",
        storageBucket: "hotel-dunamys-ay9x21.firebasestorage.app",
        messagingSenderId: "1005245374810",
        appId: "1:1005245374810:web:e42a38a63589445da99363",
      ),
    );
  } else {
    await Firebase.initializeApp();
    
    // Configurar Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Configurar handler de background para push notifications
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Inicializar serviço de push notifications
    await PushNotificationService().initialize();
  }

  // Inicializa o AppStateProvider
  final appState = AppStateProvider();
  await appState.initialize();

  // Inicializa o EnvironmentService (configurações de ambiente)
  await EnvironmentService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FAQProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider(HomeRepositoryImpl())),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Debug para ver as rotas
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return ItemCategoryScreen(categoryId: categoryId);
      },
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const MyOrdersScreen()),
    GoRoute(
      path: '/orders/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(path: '/faq', builder: (context, state) => const FAQScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
    GoRoute(
      path: '/item-details',
      builder: (context, state) {
        final item = state.extra as MenuItemModel;
        return ItemDetailsScreen(item: item);
      },
    ),
    GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
    GoRoute(
      path: '/pix-payment',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return PIXPaymentScreen(
          orderId: data['orderId'] as String,
          total: data['total'] as double,
          nome: data['nome'] as String,
          cpf: data['cpf'] as String,
        );
      },
    ),
    GoRoute(
      path: '/order-done/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderDoneScreen(orderId: orderId);
      },
    ),
    GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
    GoRoute(path: '/sac', builder: (context, state) => const SACScreen()),
    GoRoute(path: '/maps', builder: (context, state) => const MapsScreen()),
    GoRoute(path: '/gallery', builder: (context, state) => const GalleryScreen()),
    GoRoute(
      path: '/gallery/local',
      builder: (context, state) {
        final local = state.extra as LocalDunamysModel;
        return LocalSelectedScreen(local: local);
      },
    ),
    // Admin routes
    GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersScreen()),
    GoRoute(
      path: '/admin/orders/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return AdminOrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(path: '/admin/products', builder: (context, state) => const AdminProductsScreen()),
    GoRoute(
      path: '/admin/products/new',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['category'];
        return AdminProductFormScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/admin/products/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        return AdminProductFormScreen(productId: productId);
      },
    ),
    GoRoute(path: '/admin/categories', builder: (context, state) => const AdminCategoriesScreen()),
    GoRoute(path: '/admin/stock', builder: (context, state) => const AdminStockScreen()),
    GoRoute(path: '/admin/feedback', builder: (context, state) => const AdminFeedbackScreen()),
    GoRoute(path: '/admin/faq', builder: (context, state) => const AdminFAQScreen()),
    GoRoute(path: '/admin/media', builder: (context, state) => const AdminMediaScreen()),
    GoRoute(path: '/admin/reports', builder: (context, state) => const AdminReportsScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Dunamys', theme: AppTheme.lightTheme, routerConfig: _router, debugShowCheckedModeBanner: false);
  }
}
