import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../core/models/ticket.dart';
import '../../core/models/beneficiado.dart';
import '../../core/models/checkout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/beneficiado_database.dart';
import '../../core/services/pagamentos_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/sanitizers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gileade_button.dart';

class _BeneficiadoFormData {
  final nomeCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  String idade = '';
  final celularCtrl = TextEditingController(text: '+55 ');
  final igrejaCtrl = TextEditingController();
  String? sexo;
  String? papelIgreja;
  String? estadoCivil;
  final emailCtrl = TextEditingController();
  String? escolaridade;
  final cidadeCtrl = TextEditingController();
  String? estadoUf;

  void dispose() {
    nomeCtrl.dispose();
    cpfCtrl.dispose();
    celularCtrl.dispose();
    igrejaCtrl.dispose();
    emailCtrl.dispose();
    cidadeCtrl.dispose();
  }

  void preencherDoUsuario(Map<String, dynamic> u) {
    nomeCtrl.text = (u['nome'] as String?) ?? '';
    cpfCtrl.text = (u['cpf'] as String?) ?? '';
    idade = (u['idade']?.toString()) ?? '';
    celularCtrl.text = (u['celular'] as String?) ?? '+55 ';
    igrejaCtrl.text = (u['igreja'] as String?) ?? '';
    emailCtrl.text = (u['email'] as String?) ?? '';
    cidadeCtrl.text = (u['cidade'] as String?) ?? '';
    sexo = u['sexo'] as String?;
    papelIgreja = u['papel_igreja'] as String?;
    estadoCivil = u['estado_civil'] as String?;
    escolaridade = u['escolaridade'] as String?;
    estadoUf = u['estado_uf'] as String?;
  }

  void preencherDoSalvo(Beneficiado b) {
    nomeCtrl.text = b.nome;
    cpfCtrl.text = b.cpf;
    idade = b.idade?.toString() ?? '';
    celularCtrl.text = b.celular ?? '+55 ';
    igrejaCtrl.text = b.igreja ?? '';
    emailCtrl.text = b.email ?? '';
    cidadeCtrl.text = b.cidade ?? '';
    sexo = b.sexo;
    papelIgreja = b.papelIgreja;
    estadoCivil = b.estadoCivil;
    escolaridade = b.escolaridade;
    estadoUf = b.estadoUf;
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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

  final _quantidadeController = TextEditingController(text: '1');
  late Ticket _ticket;
  int _quantidade = 1;
  int _totalBeneficiados = 1;
  List<GlobalKey<FormState>> _formKeys = [];
  List<_BeneficiadoFormData> _formData = [];
  bool _loading = false;
  List<Beneficiado> _beneficiadosSalvos = [];
  bool _mostrarBeneficiadoSalvos = true;
  String _cpfBusca = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Ticket) {
        _ticket = args;
        _atualizarBeneficiados();
      } else {
        Navigator.pop(context);
      }
    });
    _carregarBeneficiadosSalvos();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    for (final d in _formData) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarBeneficiadosSalvos() async {
    try {
      _beneficiadosSalvos = await BeneficiadoDatabase().listar();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _atualizarBeneficiados() {
    final porUnidade = _ticket.beneficiadosPorUnidade();
    _totalBeneficiados = _quantidade * porUnidade;

    for (final d in _formData) {
      d.dispose();
    }

    _formKeys = List.generate(_totalBeneficiados, (_) => GlobalKey<FormState>());
    _formData = List.generate(_totalBeneficiados, (_) => _BeneficiadoFormData());
    if (mounted) setState(() {});
  }

  void _preencherComUsuario() {
    final auth = context.read<AuthProvider>();
    final u = auth.usuario;
    if (u == null) return;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Usar meus dados',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        children: List.generate(_totalBeneficiados, (i) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() {
                _formData[i].preencherDoUsuario(u.toJson());
              });
              Navigator.pop(ctx);
            },
            child: Text('Preencher Beneficiado ${i + 1}',
                style: AppTextStyles.body),
          );
        }),
      ),
    );
  }

  void _preencherComSalvo(int index, Beneficiado b) {
    setState(() {
      _formData[index].preencherDoSalvo(b);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: Text(_ticket.nome,
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketInfo(currencyFormat),
            const SizedBox(height: 20),
            _buildQuantidadeSelector(),
            const SizedBox(height: 20),
            if (_beneficiadosSalvos.isNotEmpty && _mostrarBeneficiadoSalvos) ...[
              _buildBeneficiadosSalvos(),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Text('Dados dos Beneficiados',
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _preencherComUsuario,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text('Usar meus dados',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
                _totalBeneficiados, (i) => _buildBeneficiadoForm(i)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total:', style: AppTextStyles.caption),
                      Text(
                        currencyFormat.format(_ticket.preco * _quantidade),
                        style: AppTextStyles.title.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GileadeButton(
                    label: _loading ? 'PROCESSANDO...' : 'COMPRAR',
                    onPressed: _loading ? null : _realizarCheckout,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiadosSalvos() {
    final filtrados = _cpfBusca.isEmpty
        ? _beneficiadosSalvos
        : _beneficiadosSalvos
            .where((b) =>
                b.nome.toLowerCase().contains(_cpfBusca.toLowerCase()) ||
                b.cpf.contains(_cpfBusca))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Beneficiados Salvos',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: () =>
                  setState(() => _mostrarBeneficiadoSalvos = false),
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Ocultar',
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou CPF...',
              hintStyle: AppTextStyles.caption.copyWith(fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)),
              isDense: true,
              prefixIcon:
                  const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
            ),
            style: AppTextStyles.caption.copyWith(fontSize: 13),
            onChanged: (v) => setState(() => _cpfBusca = v),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: filtrados.isEmpty
              ? Center(
                  child: Text('Nenhum beneficiado encontrado.',
                      style: AppTextStyles.caption))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtrados.length,
                  itemBuilder: (ctx, idx) {
                    final b = filtrados[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onLongPress: () => _confirmarRemoverSalvo(b),
                        child: ActionChip(
                          avatar: const Icon(Icons.person, size: 18),
                          label: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.nome,
                                style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 12)),
                            Text(b.cpf,
                                style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                        onPressed: () => _showPreencherDialog(b),
                      ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTicketInfo(NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: Icon(_iconeTicket(_ticket.tipo),
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ticket.nome,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(_ticket.descricao, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                      'Evento: ${_formatarData(_ticket.dataEvento)} - ${_ticket.tipo}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            Text(currencyFormat.format(_ticket.preco),
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantidadeSelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('Quantidade:',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _quantidade > 1
                  ? () {
                      _quantidade--;
                      _quantidadeController.text = _quantidade.toString();
                      _atualizarBeneficiados();
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.primary),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _quantidadeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700, fontSize: 18),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) {
                  final q = int.tryParse(v);
                  if (q != null &&
                      q > 0 &&
                      q <= _ticket.quantidadeDisponivel) {
                    _quantidade = q;
                    _atualizarBeneficiados();
                  }
                },
              ),
            ),
            IconButton(
              onPressed: _quantidade < _ticket.quantidadeDisponivel
                  ? () {
                      _quantidade++;
                      _quantidadeController.text = _quantidade.toString();
                      _atualizarBeneficiados();
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.primary),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalBeneficiados beneficiado${_totalBeneficiados > 1 ? 's' : ''}',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiadoForm(int index) {
    final d = _formData[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKeys[index],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Beneficiado ${index + 1}',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 14),

              // Nome
              _buildTextField('Nome completo *', d.nomeCtrl,
                  validator: (v) =>
                      requiredField(v, 'Nome e obrigatorio'),
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 10),

              // CPF
              _buildTextField('CPF (apenas numeros) *', d.cpfCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (v) {
                    final digits = digitsOnly(v ?? '');
                    if (digits.isEmpty) return 'CPF e obrigatorio';
                    if (digits.length != 11) return 'CPF deve ter 11 digitos';
                    return null;
                  }),
              const SizedBox(height: 10),

              // Idade + Celular
              Row(
                children: [
                  Expanded(
                    child: _buildIdadeField(d),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('Celular *', d.celularCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 20,
                        validator: (v) {
                          final digits = digitsOnly(v ?? '');
                          if (digits.length < 12) {
                            return 'Digite DDD + numero';
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Email
              _buildTextField('Email *', d.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail),
              const SizedBox(height: 10),

              // Sexo + Estado Civil
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Sexo *', d.sexo, _sexoOptions,
                        (v) => setState(() => d.sexo = v)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                        'Estado Civil *',
                        d.estadoCivil,
                        _estadoCivilOptions,
                        (v) => setState(() => d.estadoCivil = v)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Igreja + Papel na Igreja
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Igreja *', d.igrejaCtrl,
                        validator: (v) =>
                            requiredField(v, 'Igreja e obrigatoria')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                        'Papel na Igreja *',
                        d.papelIgreja,
                        _papelIgrejaOptions,
                        (v) => setState(() => d.papelIgreja = v)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Escolaridade
              _buildDropdown('Escolaridade *', d.escolaridade,
                  _escolaridadeOptions,
                  (v) => setState(() => d.escolaridade = v)),
              const SizedBox(height: 10),

              // Cidade + UF
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Cidade *', d.cidadeCtrl,
                        validator: (v) =>
                            requiredField(v, 'Cidade e obrigatoria')),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: _buildDropdown('UF *', d.estadoUf, _estadoUfOptions,
                        (v) => setState(() => d.estadoUf = v)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      int? maxLength,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator,
      TextCapitalization textCapitalization = TextCapitalization.none}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        counterText: '',
      ),
      style: AppTextStyles.body.copyWith(fontSize: 14),
      validator: validator ??
          ((v) => v == null || v.trim().isEmpty ? 'Campo obrigatorio' : null),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      style: AppTextStyles.body.copyWith(fontSize: 14),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatorio' : null,
      isExpanded: true,
    );
  }

  Widget _buildIdadeField(_BeneficiadoFormData d) {
    final idadeInt = int.tryParse(d.idade) ?? 18;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Idade: $idadeInt anos *',
            style: AppTextStyles.caption.copyWith(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: idadeInt.toDouble().clamp(1, 100),
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: AppColors.primary,
                label: '$idadeInt',
                onChanged: (v) {
                  setState(() => d.idade = v.round().toString());
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                initialValue: d.idade,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: AppTextStyles.body.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder(),
                  isDense: true,
                  counterText: '',
                ),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed >= 1 && parsed <= 100) {
                    setState(() => d.idade = v);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPreencherDialog(Beneficiado b) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Preencher com "${b.nome}"',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        children: List.generate(_totalBeneficiados, (i) {
          return SimpleDialogOption(
            onPressed: () {
              _preencherComSalvo(i, b);
              Navigator.pop(ctx);
            },
            child: Text('Beneficiado ${i + 1}',
                style: AppTextStyles.body),
          );
        }),
      ),
    );
  }

  void _confirmarRemoverSalvo(Beneficiado b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover beneficiado salvo'),
        content: Text('Deseja remover "${b.nome}" dos salvos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await BeneficiadoDatabase().removerPorCpf(b.cpf);
              await _carregarBeneficiadosSalvos();
            },
            child:
                Text('Remover', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _realizarCheckout() async {
    bool todosValidos = true;
    for (final key in _formKeys) {
      if (!key.currentState!.validate()) {
        todosValidos = false;
      }
    }

    for (final d in _formData) {
      if (d.sexo == null || d.sexo!.isEmpty) todosValidos = false;
      if (d.papelIgreja == null || d.papelIgreja!.isEmpty) todosValidos = false;
      if (d.estadoCivil == null || d.estadoCivil!.isEmpty) todosValidos = false;
      if (d.escolaridade == null || d.escolaridade!.isEmpty) todosValidos = false;
      if (d.estadoUf == null || d.estadoUf!.isEmpty) todosValidos = false;
    }

    if (!todosValidos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatorios.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final beneficiados = <Beneficiado>[];

      for (var i = 0; i < _totalBeneficiados; i++) {
        final d = _formData[i];
        final idadeInt = int.tryParse(d.idade) ?? 0;
        final celularRaw = d.celularCtrl.text.trim();
        final celularSanitizado = celularRaw.startsWith('+55')
            ? celularRaw
            : '+55 ${digitsOnly(celularRaw)}';

        final b = Beneficiado(
          nome: sanitizeName(d.nomeCtrl.text),
          cpf: sanitizeCpf(d.cpfCtrl.text),
          idade: idadeInt > 0 ? idadeInt : null,
          celular: celularSanitizado,
          igreja: sanitizeText(d.igrejaCtrl.text),
          papelIgreja: d.papelIgreja,
          estadoCivil: d.estadoCivil,
          email: sanitizeEmail(d.emailCtrl.text),
          sexo: d.sexo,
          cidade: sanitizeText(d.cidadeCtrl.text),
          estadoUf: d.estadoUf,
          escolaridade: d.escolaridade,
        );
        beneficiados.add(b);

        try {
          await BeneficiadoDatabase().salvar(b);
        } catch (_) {}
      }

      final service = PagamentosService(auth.client);
      final request = CheckoutRequest(
        usuarioId: auth.usuario!.id,
        ticketId: _ticket.id,
        quantidade: _quantidade,
        beneficiados: beneficiados,
      );

      final response = await service.criarCheckout(request);

      if (!mounted) return;
      await _abrirCheckout(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrirCheckout(CheckoutResponse response) async {
    final url = Uri.parse(response.initPoint);

    try {
      if (Platform.isAndroid) {
        await launchUrl(
          url,
          customTabsOptions: CustomTabsOptions(
            colorSchemes: CustomTabsColorSchemes.defaults(
              toolbarColor: AppColors.primary,
            ),
            shareState: CustomTabsShareState.off,
            urlBarHidingEnabled: true,
            showTitle: true,
            closeButton: CustomTabsCloseButton(
              icon: CustomTabsCloseButtonIcons.back,
            ),
          ),
        );
      } else {
        await url_launcher.launchUrl(
          url,
          mode: url_launcher.LaunchMode.inAppWebView,
          webViewConfiguration: const url_launcher.WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }
    } catch (e) {
      try {
        await url_launcher.launchUrl(
          url,
          mode: url_launcher.LaunchMode.externalApplication,
        );
      } catch (_) {}
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Pagamento'),
        content: const Text(
          'Verifique o status do seu ticket na tela "Meus Tickets".\n\n'
          'Se o pagamento foi aprovado, o status sera atualizado automaticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
              if (mounted) {
                context.read<AuthProvider>();
              }
            },
            child: const Text('VOLTAR AO INICIO'),
          ),
        ],
      ),
    );
  }

  IconData _iconeTicket(String tipo) {
    switch (tipo) {
      case 'Duo':
        return Icons.group;
      case 'Caravana':
        return Icons.directions_bus;
      default:
        return Icons.confirmation_number;
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
