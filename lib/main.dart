import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/providers.dart';
import 'providers/favourites_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'providers/movie_booking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthProvider();
  await auth.loadSession(); // ✅ session restore

  runApp(FastKartApp(auth: auth));
}

class FastKartApp extends StatelessWidget {
  final AuthProvider auth;
  const FastKartApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()), // ✅ cart restore
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MovieBookingProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeProvider>().themeMode;
          AppRouter.setAuth(context.read<AuthProvider>());
          return MaterialApp.router(
            title: 'FastKart',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}