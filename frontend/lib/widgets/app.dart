import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/auth.page.dart';
import 'package:frontend/widgets/pages/home.page.dart';
import 'package:frontend/widgets/pages/login.page.dart';
import 'package:frontend/widgets/pages/register.page.dart';
import 'package:go_router/go_router.dart';

import '../../constants/ui.dart';
import '../enums/route.enum.dart';

class App extends StatelessWidget {
  App({super.key});

  final _router = GoRouter(
    initialLocation: RouteEnum.auth.value,
    routes: [
      GoRoute(
        path: RouteEnum.auth.value,
        builder: (context, state) => AuthPage.onCreate(),
      ),
      GoRoute(
        path: RouteEnum.login.value,
        builder: (context, state) => LoginPage.onCreate(),
      ),
      GoRoute(
        path: RouteEnum.register.value,
        builder: (context, state) => RegisterPage.onCreate(),
      ),
      GoRoute(
        path: RouteEnum.home.value,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
        ),
      ),
      routerConfig: _router,
    );
  }
}