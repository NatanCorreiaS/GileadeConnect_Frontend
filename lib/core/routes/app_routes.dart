import 'package:flutter/material.dart';

import '../../features/admin/admin_dashboard_page.dart';
import '../../features/admin/admin_ticket_form_page.dart';
import '../../features/admin/admin_tickets_page.dart';
import '../../features/admin/admin_export_page.dart';
import '../../features/admin/admin_usuario_edit_page.dart';
import '../../features/admin/admin_usuarios_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/home/home_page.dart';
import '../../features/tickets/checkout_page.dart';
import '../../features/tickets/meus_tickets_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const checkout = '/checkout';
  static const meusTickets = '/meus-tickets';
  static const admin = '/admin';
  static const adminTickets = '/admin/tickets';
  static const adminTicketForm = '/admin/tickets/form';
  static const adminUsuarios = '/admin/usuarios';
  static const adminUsuarioEdit = '/admin/usuarios/edit';
  static const adminExport = '/admin/export';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const HomePage(),
      login: (_) => const LoginPage(),
      register: (_) => const RegisterPage(),
      checkout: (_) => const CheckoutPage(),
      meusTickets: (_) => const MeusTicketsPage(),
      admin: (_) => const AdminDashboardPage(),
      adminTickets: (_) => const AdminTicketsPage(),
      adminTicketForm: (_) => const AdminTicketFormPage(),
      adminUsuarios: (_) => const AdminUsuariosPage(),
      adminUsuarioEdit: (_) => const AdminUsuarioEditPage(),
      adminExport: (_) => const AdminExportPage(),
    };
  }
}
