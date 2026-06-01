import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gileade_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 68,
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
                Text(
                  'App de inscricao de eventos da Igreja Gileade',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                GileadeButton(
                  label: 'ENTRAR',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                ),
                const SizedBox(height: 16),
                GileadeButton(
                  label: 'CADASTRAR',
                  isOutline: true,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
