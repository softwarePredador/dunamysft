import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/menu/menu_screen.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD1pui2pXaHAwKZx4g8EgcrajUk5J69AI8",
            authDomain: "hotel-dunamys-ay9x21.firebaseapp.com",
            projectId: "hotel-dunamys-ay9x21",
            storageBucket: "hotel-dunamys-ay9x21.firebasestorage.app",
            messagingSenderId: "1005245374810",
            appId: "1:1005245374810:web:e42a38a63589445da99363"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dunamys',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
