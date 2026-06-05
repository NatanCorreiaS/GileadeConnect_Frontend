import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return;
      }
      context.read<AdminProvider>().carregarTickets();
      context.read<AdminProvider>().carregarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final tickets = adminProvider.tickets;
    final usuarios = adminProvider.usuarios;
    final authProvider = context.watch<AuthProvider>();

    final totalTickets = tickets.fold<int>(0, (s, t) => s + t.quantidadeDisponivel);
    final totalUsuarios = usuarios.length;
    final admins = usuarios.where((u) => u.tipoUsuario == 'Admin').length;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Painel de Controle',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context, authProvider),
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: Text('Sair',
                style: AppTextStyles.caption.copyWith(color: Colors.white)),
          ),
        ],
      ),
      body: adminProvider.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumo',
                      style: AppTextStyles.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Tickets Disp.', '$totalTickets', Icons.confirmation_number, AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Usuarios', '$totalUsuarios', Icons.people, Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Admins', '$admins', Icons.admin_panel_settings, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildMenuLink('Gerenciar Tickets',
                      'Criar, editar ou remover tickets',
                      Icons.confirmation_number,
                      AppRoutes.adminTickets),
                  const SizedBox(height: 8),
                  _buildMenuLink('Gerenciar Usuarios',
                      'Visualizar, editar ou remover usuarios',
                      Icons.people,
                      AppRoutes.adminUsuarios),
                  const SizedBox(height: 28),
                  Text('Tickets Recentes',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (tickets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Nenhum ticket cadastrado.',
                            style: AppTextStyles.caption),
                      ),
                    )
                  else
                    ...tickets.take(5).map((t) => ListTile(
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.confirmation_number,
                                color: AppColors.primary, size: 20),
                          ),
                          title: Text(t.nome, style: AppTextStyles.body),
                          subtitle: Text('${t.quantidadeDisponivel} disponiveis',
                              style: AppTextStyles.caption),
                          trailing: Text('R\$ ${t.preco.toStringAsFixed(2)}',
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700, color: AppColors.primary)),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 22, color: color)),
            Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuLink(String title, String subtitle, IconData icon, String route) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    }
  }
}
