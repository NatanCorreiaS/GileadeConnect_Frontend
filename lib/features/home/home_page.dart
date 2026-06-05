import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/ticket.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/tickets_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gileade_button.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
        return;
      }
      _carregarTickets();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _carregarTickets();
  }

  void _carregarTickets() {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && !auth.isAdmin) {
      context.read<TicketsProvider>().carregarTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

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
          child: isAuthenticated
              ? _buildAuthenticated(authProvider)
              : _buildPublico(authProvider),
        ),
      ),
    );
  }

  Widget _buildPublico(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Image.asset('assets/Gileade_logo.png', width: 200, height: 200),
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildAuthenticated(AuthProvider authProvider) {
    final usuario = authProvider.usuario!;
    final ticketsProvider = context.watch<TicketsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.account_circle_rounded,
                  color: Colors.white, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ola, ${usuario.nome.split(' ').first}',
                        style: AppTextStyles.subtitle
                            .copyWith(color: Colors.white)),
                    Text(usuario.email,
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.receipt_long, color: Colors.white),
                tooltip: 'Meus Tickets',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.meusTickets),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sair',
                onPressed: () => _logout(context, authProvider),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Tickets Disponiveis',
              style: AppTextStyles.title.copyWith(
                  color: Colors.white, fontSize: 22)),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTicketsList(ticketsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(TicketsProvider ticketsProvider) {
    if (ticketsProvider.loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (ticketsProvider.erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erro ao carregar tickets',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            GileadeButton(
              label: 'TENTAR NOVAMENTE',
              onPressed: () => ticketsProvider.carregarTickets(),
            ),
          ],
        ),
      );
    }

    if (ticketsProvider.tickets.isEmpty) {
      return Center(
        child: Text('Nenhum ticket disponivel no momento.',
            style: AppTextStyles.body.copyWith(color: Colors.white70)),
      );
    }

    final ticketsDisponiveis = ticketsProvider.tickets
        .where((t) => t.quantidadeDisponivel > 0)
        .toList();

    if (ticketsDisponiveis.isEmpty) {
      return Center(
        child: Text('Todos os tickets estao esgotados.',
            style: AppTextStyles.body.copyWith(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ticketsProvider.carregarTickets(),
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: ticketsDisponiveis.length,
        padding: const EdgeInsets.only(bottom: 20),
        itemBuilder: (context, index) =>
            _buildTicketCard(ticketsDisponiveis[index]),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, AppRoutes.checkout,
            arguments: ticket),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ticket.tipo == 'Duo'
                      ? Icons.group
                      : ticket.tipo == 'Caravana'
                          ? Icons.directions_bus
                          : Icons.confirmation_number,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.nome,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(ticket.descricao,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(_formatarData(ticket.dataEvento),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currencyFormat.format(ticket.preco),
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ticket.quantidadeDisponivel <= 10
                          ? AppColors.danger.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${ticket.quantidadeDisponivel} un.',
                        style: AppTextStyles.caption.copyWith(
                            color: ticket.quantidadeDisponivel <= 10
                                ? AppColors.danger
                                : Colors.green,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    } catch (_) {
      return data;
    }
  }

  Future<void> _logout(
      BuildContext context, AuthProvider authProvider) async {
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
