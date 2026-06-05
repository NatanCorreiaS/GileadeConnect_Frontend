import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/ticket.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminProvider>().carregarTickets());
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final tickets = adminProvider.tickets;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Gerenciar Tickets',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.adminTicketForm);
          if (result == true) {
            if (context.mounted) context.read<AdminProvider>().carregarTickets();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: adminProvider.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : tickets.isEmpty
              ? Center(
                  child: Text('Nenhum ticket cadastrado.',
                      style: AppTextStyles.caption))
              : RefreshIndicator(
                  onRefresh: () => adminProvider.carregarTickets(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) =>
                        _buildTicketCard(tickets[index], adminProvider, currencyFormat),
                  ),
                ),
    );
  }

  Widget _buildTicketCard(
      Ticket ticket, AdminProvider adminProvider, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(ticket.tipo.substring(0, 1),
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.nome,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(ticket.descricao,
                          style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currencyFormat.format(ticket.preco),
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
                    Text('${ticket.quantidadeDisponivel} un.',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.adminTicketForm,
                      arguments: ticket,
                    );
                    if (!mounted) return;
                    if (result == true) {
                      context.read<AdminProvider>().carregarTickets();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text('Editar', style: AppTextStyles.caption),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmarRemover(ticket, adminProvider),
                  icon: const Icon(Icons.delete, size: 18, color: AppColors.danger),
                  label: Text('Remover',
                      style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarRemover(Ticket ticket, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar remocao'),
        content: Text('Deseja remover o ticket "${ticket.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await adminProvider.removerTicket(ticket.id);
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
