import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminExportPage extends StatelessWidget {
  const AdminExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Exportar Dados',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExportCard(
            context,
            titulo: 'Usuarios',
            descricao: 'Exporta todos os usuarios cadastrados (ID, Nome, CPF, Email, Igreja, etc.)',
            icone: Icons.people,
            exportando: adminProvider.exportando,
            onExportar: () => _exportar(context, adminProvider.exportarUsuarios),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            titulo: 'Tickets',
            descricao: 'Exporta todos os tickets cadastrados (ID, Tipo, Nome, Preco, Data do Evento, etc.)',
            icone: Icons.confirmation_number,
            exportando: adminProvider.exportando,
            onExportar: () => _exportar(context, adminProvider.exportarTickets),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            titulo: 'Tickets Compra',
            descricao: 'Exporta todas as compras de tickets com nome e CPF do comprador',
            icone: Icons.shopping_cart,
            exportando: adminProvider.exportando,
            onExportar: () => _exportar(context, adminProvider.exportarTicketsCompra),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            titulo: 'Pagamentos',
            descricao: 'Exporta todos os pagamentos realizados (ID Transacao, Valor, Metodo, Status, etc.)',
            icone: Icons.payment,
            exportando: adminProvider.exportando,
            onExportar: () => _exportar(context, adminProvider.exportarPagamentos),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            titulo: 'Beneficiados',
            descricao: 'Exporta todos os beneficiados cadastrados (ID, Nome, CPF, Idade, Igreja, etc.)',
            icone: Icons.card_giftcard,
            exportando: adminProvider.exportando,
            onExportar: () => _exportar(context, adminProvider.exportarBeneficiados),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required String titulo,
    required String descricao,
    required IconData icone,
    required bool exportando,
    required VoidCallback onExportar,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(descricao, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            exportando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : IconButton(
                    onPressed: onExportar,
                    icon: const Icon(Icons.download, color: AppColors.primary),
                    tooltip: 'Baixar CSV',
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportar(
    BuildContext context,
    Future<String> Function() exportFn,
  ) async {
    try {
      final caminho = await exportFn();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arquivo salvo em: $caminho'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
