import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/providers.dart';
import 'providers/favourites_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

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
            theme: ThemeData(
              colorSchemeSeed: AppColors.primary,
              useMaterial3: true,
              fontFamily: 'Poppins',
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: AppColors.primary,
              brightness: Brightness.dark,
              useMaterial3: true,
              fontFamily: 'Poppins',
            ),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}