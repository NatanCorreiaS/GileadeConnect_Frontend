import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/ticket.dart';
import '../../core/models/ticket_compra.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/tickets_compra_service.dart';
import '../../core/services/tickets_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MeusTicketsPage extends StatefulWidget {
  const MeusTicketsPage({super.key});

  @override
  State<MeusTicketsPage> createState() => _MeusTicketsPageState();
}

class _MeusTicketsPageState extends State<MeusTicketsPage> {
  List<TicketCompra> _compras = [];
  Map<int, Ticket> _ticketsMap = {};
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final compraService = TicketsCompraService(auth.client);
      final ticketService = TicketsService(auth.client);

      final results = await Future.wait([
        compraService.listarComprasUsuario(auth.usuario!.id),
        ticketService.listarTickets(),
      ]);

      _compras = results[0] as List<TicketCompra>;
      final tickets = results[1] as List<Ticket>;
      _ticketsMap = {for (final t in tickets) t.id: t};
    } catch (e) {
      _erro = e.toString();
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Meus Tickets',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erro ao carregar tickets',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _carregarDados,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('TENTAR NOVAMENTE',
                  style: AppTextStyles.button.copyWith(fontSize: 14)),
            ),
          ],
        ),
      );
    }

    if (_compras.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Nenhum ticket encontrado',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Compre um ticket na tela inicial',
                style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _compras.length,
        itemBuilder: (context, index) =>
            _buildCompraCard(_compras[index]),
      ),
    );
  }

  Widget _buildCompraCard(TicketCompra compra) {
    final statusColor = _corStatus(compra.status);
    final statusIcon = _iconeStatus(compra.status);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final ticket = _ticketsMap[compra.ticketId];
    final nomeTicket = ticket?.nome ?? 'Ticket #${compra.ticketId}';
    final descricaoTicket = ticket?.descricao ?? '';
    final precoTicket = ticket?.preco ?? 0;
    final dataEvento = ticket?.dataEvento;
    final tipo = ticket?.tipo ?? '';

    final totalCompra = precoTicket * compra.quantidade;

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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nomeTicket,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      if (descricaoTicket.isNotEmpty)
                        Text(descricaoTicket,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(compra.status,
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _infoColuna('Qtd.', '${compra.quantidade}x'),
                if (tipo.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _infoColuna('Tipo', tipo),
                ],
                const Spacer(),
                _infoColuna('Valor Unit.',
                    currencyFormat.format(precoTicket)),
                const SizedBox(width: 16),
                _infoColuna('Total',
                    currencyFormat.format(totalCompra)),
              ],
            ),
            if (dataEvento != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Evento: ${_formatarData(dataEvento)}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoColuna(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(valor,
            style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'Pago':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Cancelado':
        return AppColors.danger;
      case 'Reembolsado':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case 'Pago':
        return Icons.check_circle;
      case 'Pendente':
        return Icons.access_time;
      case 'Cancelado':
        return Icons.cancel;
      case 'Reembolsado':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    } catch (_) {
      return data;
    }
  }
}
