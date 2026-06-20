import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/providers.dart';
import 'providers/favourites_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'providers/movie_booking_provider.dart';

void main() {
  runApp(const FastKartApp());
}

class FastKartApp extends StatelessWidget {
  const FastKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MovieBookingProvider()),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.read<AuthProvider>();
          final themeMode = context.watch<ThemeProvider>().themeMode;
          AppRouter.setAuth(auth);
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