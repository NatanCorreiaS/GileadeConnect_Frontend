import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/models/pessoa_create_request.dart';
import '../../core/services/api_client.dart';
import '../../core/services/pessoas_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/crypto_utils.dart';
import '../../core/utils/sanitizers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gileade_button.dart';
import '../../core/widgets/gileade_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const List<String> _sexoOptions = [
    'Masculino',
    'Feminino',
  ];

  static const List<String> _papelIgrejaOptions = [
    'Pastor',
    'Lider',
    'Voluntario',
    'Membro',
  ];

  static const List<String> _estadoCivilOptions = [
    'Solteiro(a)',
    'Casado(a)',
    'Divorciado(a)',
    'Viuvo(a)',
  ];

  static const List<String> _estadoUfOptions = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  static const List<String> _escolaridadeOptions = [
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
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _igrejaController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int _idade = 18;
  String? _sexo;
  String? _papelIgreja;
  String? _estadoCivil;
  String? _estadoUf;
  String? _escolaridade;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _loading = false;

  late final PessoasService _pessoasService;

  @override
  void initState() {
    super.initState();
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
    _pessoasService = PessoasService(ApiClient(baseUrl: baseUrl));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _igrejaController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    return requiredField(value, 'Informe seu nome.');
  }

  String? _validateConfirmPassword(String? value) {
    final required = requiredField(value, 'Confirme sua senha.');
    if (required != null) {
      return required;
    }
    if (value!.trim() != _passwordController.text.trim()) {
      return 'As senhas nao coincidem.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aceite os termos para continuar.')),
      );
      return;
    }

    setState(() => _loading = true);

    final nome = sanitizeName(_nameController.text);
    final cpf = sanitizeCpf(_cpfController.text);
    final celular = sanitizePhone(_phoneController.text);
    final igreja = sanitizeText(_igrejaController.text);
    final papelIgreja = sanitizeText(_papelIgreja ?? '');
    final estadoCivil = sanitizeText(_estadoCivil ?? '');
    final email = sanitizeEmail(_emailController.text);
    final sexo = sanitizeText(_sexo ?? '');
    final cidade = sanitizeText(_cidadeController.text);
    final estadoUf = sanitizeUf(_estadoUf ?? '');
    final escolaridade = sanitizeText(_escolaridade ?? '');
    final senha = sanitizePassword(_passwordController.text);
    final senhaHash = hashSenha(senha);

    final request = PessoaCreateRequest(
      nome: nome,
      email: email,
      senhaHash: senhaHash,
      cpf: cpf,
      idade: _idade,
      celular: celular,
      igreja: igreja,
      papelIgreja: papelIgreja,
      estadoCivil: estadoCivil,
      sexo: sexo,
      cidade: cidade,
      estadoUf: estadoUf,
      escolaridade: escolaridade,
    );

    try {
      await _pessoasService.criarPessoa(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cadastro', style: AppTextStyles.title),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coloque seu nome', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _nameController,
                      hintText: 'Nome Completo',
                      validator: _validateName,
                    ),
                    const SizedBox(height: 18),
                    Text('CPF', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _cpfController,
                      hintText: '00000000000',
                      keyboardType: TextInputType.number,
                      validator: validateCpf,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Idade', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    Text('$_idade anos', style: AppTextStyles.body),
                    Slider(
                      min: 10,
                      max: 100,
                      divisions: 90,
                      value: _idade.toDouble(),
                      label: '$_idade',
                      onChanged: (value) {
                        setState(() => _idade = value.round());
                      },
                    ),
                    const SizedBox(height: 18),
                    Text('Celular', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _phoneController,
                      hintText: '11999990000',
                      keyboardType: TextInputType.phone,
                      validator: validateCelular,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Igreja', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _igrejaController,
                      hintText: 'Igreja',
                      validator: (value) =>
                          requiredField(value, 'Informe a igreja.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Papel na igreja', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    _DropdownField(
                      value: _papelIgreja,
                      hintText: 'Selecione',
                      items: _papelIgrejaOptions,
                      onChanged: (value) {
                        setState(() => _papelIgreja = value);
                      },
                      validator: (value) =>
                          requiredField(value, 'Informe o papel na igreja.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Estado civil', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    _DropdownField(
                      value: _estadoCivil,
                      hintText: 'Selecione',
                      items: _estadoCivilOptions,
                      onChanged: (value) {
                        setState(() => _estadoCivil = value);
                      },
                      validator: (value) =>
                          requiredField(value, 'Informe o estado civil.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Coloque seu E-mail', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _emailController,
                      hintText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 18),
                    Text('Sexo', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    _DropdownField(
                      value: _sexo,
                      hintText: 'Selecione',
                      items: _sexoOptions,
                      onChanged: (value) {
                        setState(() => _sexo = value);
                      },
                      validator: (value) =>
                          requiredField(value, 'Informe o sexo.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Cidade', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _cidadeController,
                      hintText: 'Cidade',
                      validator: (value) =>
                          requiredField(value, 'Informe a cidade.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Estado (UF)', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    _DropdownField(
                      value: _estadoUf,
                      hintText: 'Selecione',
                      items: _estadoUfOptions,
                      onChanged: (value) {
                        setState(() => _estadoUf = value);
                      },
                      validator: (value) =>
                          requiredField(value, 'Informe o estado UF.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Escolaridade', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    _DropdownField(
                      value: _escolaridade,
                      hintText: 'Selecione',
                      items: _escolaridadeOptions,
                      onChanged: (value) {
                        setState(() => _escolaridade = value);
                      },
                      validator: (value) =>
                          requiredField(value, 'Informe a escolaridade.'),
                    ),
                    const SizedBox(height: 18),
                    Text('Senha', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _passwordController,
                      hintText: '************',
                      obscureText: _obscurePassword,
                      validator: validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Confirme a senha', style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    GileadeTextField(
                      controller: _confirmController,
                      hintText: '************',
                      obscureText: _obscureConfirm,
                      validator: _validateConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() => _acceptedTerms = value ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Concordo com os Termos e a Politica de Privacidade',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GileadeButton(
                      label: _loading ? 'Carregando...' : 'Confirme',
                      onPressed: _loading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.validator,
  });

  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(hintText: hintText),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
