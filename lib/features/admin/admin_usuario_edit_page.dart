import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/models/login_response.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/sanitizers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gileade_button.dart';

class AdminUsuarioEditPage extends StatefulWidget {
  const AdminUsuarioEditPage({super.key});

  @override
  State<AdminUsuarioEditPage> createState() => _AdminUsuarioEditPageState();
}

class _AdminUsuarioEditPageState extends State<AdminUsuarioEditPage> {
  static const _sexoOptions = ['Masculino', 'Feminino'];
  static const _papelIgrejaOptions = ['Pastor', 'Lider', 'Voluntario', 'Membro'];
  static const _estadoCivilOptions = ['Solteiro(a)', 'Casado(a)', 'Divorciado(a)', 'Viuvo(a)'];
  static const _estadoUfOptions = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];
  static const _escolaridadeOptions = [
    'Ensino Fundamental Incompleto',
    'Ensino Fundamental Completo',
    'Ensino Medio Incompleto',
    'Ensino Medio Completo',
    'Ensino Superior Incompleto',
    'Ensino Superior Completo',
    'Pos-graduado',
    'Mestrado',
    'Doutorado',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();
  final _igrejaController = TextEditingController();
  final _cidadeController = TextEditingController();
  String _tipoUsuario = 'Usuario';
  String? _sexo;
  String? _papelIgreja;
  String? _estadoCivil;
  String? _estadoUf;
  String? _escolaridade;
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
        _cidadeController.text = args.cidade;
        _tipoUsuario = args.tipoUsuario;
        _sexo = args.sexo;
        _papelIgreja = args.papelIgreja;
        _estadoCivil = args.estadoCivil;
        _estadoUf = args.estadoUf;
        _escolaridade = args.escolaridade;
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
    _cidadeController.dispose();
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
              _buildDropdown(
                value: _tipoUsuario,
                items: ['Usuario', 'Admin'],
                onChanged: (v) => setState(() => _tipoUsuario = v ?? 'Usuario'),
              ),
              const SizedBox(height: 16),
              _buildField('Nome', _nomeController,
                  validator: validateNome,
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 16),
              _buildField('Email', _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  inputFormatters: [LowerCaseTextFormatter()]),
              const SizedBox(height: 16),
              _buildField('CPF', _cpfController, enabled: false),
              const SizedBox(height: 16),
              _buildField('Celular', _celularController,
                  keyboardType: TextInputType.phone,
                  validator: validateCelular,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _sexo,
                      items: _sexoOptions,
                      label: 'Sexo',
                      onChanged: (v) => setState(() => _sexo = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _estadoCivil,
                      items: _estadoCivilOptions,
                      label: 'Estado Civil',
                      onChanged: (v) => setState(() => _estadoCivil = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Igreja', _igrejaController,
                  validator: validateNome,
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _papelIgreja,
                      items: _papelIgrejaOptions,
                      label: 'Papel na Igreja',
                      onChanged: (v) => setState(() => _papelIgreja = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _escolaridade,
                      items: _escolaridadeOptions,
                      label: 'Escolaridade',
                      onChanged: (v) => setState(() => _escolaridade = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Cidade', _cidadeController,
                        validator: validateNome,
                        textCapitalization: TextCapitalization.words),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: _buildDropdown(
                      value: _estadoUf,
                      items: _estadoUfOptions,
                      label: 'UF',
                      onChanged: (v) => setState(() => _estadoUf = v),
                    ),
                  ),
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
      {TextInputType? keyboardType,
      bool enabled = true,
      String? Function(String?)? validator,
      TextCapitalization textCapitalization = TextCapitalization.none,
      List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: AppTextStyles.body.copyWith(fontSize: 15),
      validator: validator ??
          ((v) => v == null || v.trim().isEmpty ? 'Campo obrigatorio' : null),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? label,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      items: items
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatorio' : null,
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final adminProvider = context.read<AdminProvider>();
      final dados = <String, dynamic>{
        'nome': sanitizeName(_nomeController.text),
        'email': sanitizeEmail(_emailController.text),
        'celular': sanitizePhone(_celularController.text),
        'igreja': sanitizeText(_igrejaController.text),
        'cidade': sanitizeText(_cidadeController.text),
        'tipo_usuario': _tipoUsuario,
        'sexo': sanitizeText(_sexo ?? ''),
        'papel_igreja': sanitizeText(_papelIgreja ?? ''),
        'estado_civil': sanitizeText(_estadoCivil ?? ''),
        'estado_uf': sanitizeUf(_estadoUf ?? ''),
        'escolaridade': sanitizeText(_escolaridade ?? ''),
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
