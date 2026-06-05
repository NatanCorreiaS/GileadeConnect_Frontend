import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/ticket.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gileade_button.dart';

class AdminTicketFormPage extends StatefulWidget {
  const AdminTicketFormPage({super.key});

  @override
  State<AdminTicketFormPage> createState() => _AdminTicketFormPageState();
}

class _AdminTicketFormPageState extends State<AdminTicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _dataEventoController = TextEditingController();
  bool _loading = false;
  Ticket? _edicaoTicket;

  final _tipos = ['Individual', 'Duo', 'Caravana'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Ticket) {
        _edicaoTicket = args;
        _tipoController.text = args.tipo;
        _nomeController.text = args.nome;
        _descricaoController.text = args.descricao;
        _precoController.text = args.preco.toStringAsFixed(2);
        _quantidadeController.text = args.quantidadeDisponivel.toString();
        _dataEventoController.text = args.dataEvento;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _dataEventoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = _edicaoTicket != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Ticket' : 'Novo Ticket',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo do Ticket *',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _tipos.contains(_tipoController.text) ? _tipoController.text : null,
                items: _tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => _tipoController.text = v ?? '',
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Selecione o tipo' : null,
              ),
              const SizedBox(height: 16),
              _buildField('Nome do Ticket *', _nomeController),
              const SizedBox(height: 16),
              _buildField('Descricao *', _descricaoController, maxLines: 3),
              const SizedBox(height: 16),
              _buildField('Preco (R\$) *', _precoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              _buildField('Quantidade Disponivel *', _quantidadeController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 28),
              GileadeButton(
                label: _loading
                    ? 'SALVANDO...'
                    : isEdicao
                        ? 'ATUALIZAR TICKET'
                        : 'CRIAR TICKET',
                onPressed: _loading ? null : _salvar,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: AppTextStyles.body.copyWith(fontSize: 15),
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatorio' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dataEventoController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Data do Evento *',
        suffixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: AppTextStyles.body.copyWith(fontSize: 15),
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatorio' : null,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (date != null) {
          _dataEventoController.text =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final adminProvider = context.read<AdminProvider>();
      final dados = {
        'tipo': _tipoController.text,
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'preco': _precoController.text.trim(),
        'quantidade_disponivel': int.parse(_quantidadeController.text.trim()),
        'data_evento': _dataEventoController.text.trim(),
      };

      if (_edicaoTicket != null) {
        await adminProvider.atualizarTicket(_edicaoTicket!.id, dados);
      } else {
        await adminProvider.criarTicket(dados);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
