import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/login_response.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminProvider>().carregarUsuarios());
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final usuarios = adminProvider.usuarios;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Gerenciar Usuarios',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: adminProvider.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : usuarios.isEmpty
              ? Center(
                  child: Text('Nenhum usuario cadastrado.',
                      style: AppTextStyles.caption))
              : RefreshIndicator(
                  onRefresh: () => adminProvider.carregarUsuarios(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) =>
                        _buildUsuarioCard(usuarios[index], adminProvider),
                  ),
                ),
    );
  }

  Widget _buildUsuarioCard(Usuario usuario, AdminProvider adminProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: usuario.tipoUsuario == 'Admin'
              ? Colors.orange
              : AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
            style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: usuario.tipoUsuario == 'Admin'
                    ? Colors.white
                    : AppColors.primary),
          ),
        ),
        title: Text(usuario.nome,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('${usuario.email}\nCPF: ${usuario.cpf}',
            style: AppTextStyles.caption),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'editar') {
              Navigator.pushNamed(context, AppRoutes.adminUsuarioEdit,
                  arguments: usuario);
            } else if (action == 'remover') {
              _confirmarRemover(usuario, adminProvider);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(
                value: 'remover',
                child: Text('Remover',
                    style: TextStyle(color: AppColors.danger))),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _confirmarRemover(Usuario usuario, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar remocao'),
        content: Text('Deseja remover o usuario "${usuario.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await adminProvider.removerUsuario(usuario.id);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            child: Text('Remover',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
