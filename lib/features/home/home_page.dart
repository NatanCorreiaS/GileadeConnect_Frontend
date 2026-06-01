import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gileade_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final usuario = authProvider.usuario;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/Gileade_logo.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 12),
                Text(
                  'GILEADECONNECT',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(flex: 3),
                if (isAuthenticated && usuario != null) ...[
                  const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ola, ${usuario.nome}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  GileadeButton(
                    label: 'SAIR',
                    onPressed: () => _logout(context, authProvider),
                  ),
                ] else ...[
                  Text(
                    'App de inscricao de eventos da Igreja Gileade',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  GileadeButton(
                    label: 'ENTRAR',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                  ),
                  const SizedBox(height: 16),
                  GileadeButton(
                    label: 'CADASTRAR',
                    isOutline: true,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                  ),
                ],
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    try {
      await authProvider.logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout realizado com sucesso.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no logout: $error')),
        );
      }
    }
  }
}
