import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/login_response.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gileade_button.dart';

class AdminUsuarioEditPage extends StatefulWidget {
  const AdminUsuarioEditPage({super.key});

  @override
  State<AdminUsuarioEditPage> createState() => _AdminUsuarioEditPageState();
}

class _AdminUsuarioEditPageState extends State<AdminUsuarioEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();
  final _igrejaController = TextEditingController();
  final _papelIgrejaController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoUfController = TextEditingController();
  String _tipoUsuario = 'Usuario';
  bool _loading = false;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Usuario) {
        _usuario = args;
        _nomeController.text = args.nome;
        _emailController.text = args.email;
        _cpfController.text = args.cpf;
        _celularController.text = args.celular;
        _igrejaController.text = args.igreja;
        _papelIgrejaController.text = args.papelIgreja;
        _cidadeController.text = args.cidade;
        _estadoUfController.text = args.estadoUf;
        _tipoUsuario = args.tipoUsuario;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _celularController.dispose();
    _igrejaController.dispose();
    _papelIgrejaController.dispose();
    _cidadeController.dispose();
    _estadoUfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Usuario')),
        body: const Center(child: Text('Usuario nao encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text('Editar ${_usuario!.nome.split(' ').first}',
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
              Text('Cargo', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _tipoUsuario,
                items: ['Usuario', 'Admin']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoUsuario = v ?? 'Usuario'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              _buildField('Nome', _nomeController),
              const SizedBox(height: 16),
              _buildField('Email', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('CPF', _cpfController, enabled: false),
              const SizedBox(height: 16),
              _buildField('Celular', _celularController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField('Igreja', _igrejaController),
              const SizedBox(height: 16),
              _buildField('Papel na Igreja', _papelIgrejaController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Cidade', _cidadeController)),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: _buildField('UF', _estadoUfController)),
                ],
              ),
              const SizedBox(height: 28),
              GileadeButton(
                label: _loading ? 'SALVANDO...' : 'ATUALIZAR USUARIO',
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
      {TextInputType? keyboardType, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final adminProvider = context.read<AdminProvider>();
      final dados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'celular': _celularController.text.trim(),
        'igreja': _igrejaController.text.trim(),
        'papel_igreja': _papelIgrejaController.text.trim(),
        'cidade': _cidadeController.text.trim(),
        'estado_uf': _estadoUfController.text.trim(),
        'tipo_usuario': _tipoUsuario,
      };

      await adminProvider.atualizarUsuario(_usuario!.id, dados);
      if (mounted) Navigator.pop(context);
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
