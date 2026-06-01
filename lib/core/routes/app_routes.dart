import 'package:flutter/material.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/home/home_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const HomePage(),
      login: (_) => const LoginPage(),
      register: (_) => const RegisterPage(),
    };
  }
}
