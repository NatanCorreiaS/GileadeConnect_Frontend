import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/providers/admin_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/tickets_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'main.dart';

class GileadeApp extends StatelessWidget {
  const GileadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TicketsProvider>(
          create: (ctx) => TicketsProvider(ctx.read<AuthProvider>().client),
          update: (ctx, auth, previous) =>
              previous ?? TicketsProvider(auth.client),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (ctx) => AdminProvider(ctx.read<AuthProvider>().client),
          update: (ctx, auth, previous) =>
              previous ?? AdminProvider(auth.client),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Gileade',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
