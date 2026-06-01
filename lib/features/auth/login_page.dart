import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/crypto_utils.dart';
import '../../core/utils/sanitizers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gileade_button.dart';
import '../../core/widgets/gileade_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
    _authService = AuthService(ApiClient(baseUrl: baseUrl));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);

    final email = sanitizeEmail(_emailController.text);
    final senha = sanitizePassword(_passwordController.text);
    final senhaHash = hashSenha(senha);

    try {
      await _authService.login(email: email, senhaHash: senhaHash);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login: $error')),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar', style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(
                        'Entre e faca sua inscricao para o nosso evento',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 28),
                      GileadeTextField(
                        controller: _emailController,
                        hintText: 'E-mail',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 18),
                      GileadeTextField(
                        controller: _passwordController,
                        hintText: 'Senha',
                        prefixIcon: Icons.lock_outline,
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Esqueci a minha senha'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GileadeButton(
                        label: _loading ? 'Carregando...' : 'ENTRAR',
                        onPressed: _loading ? null : _submit,
                      ),
                      const SizedBox(height: 16),
                      GileadeButton(
                        label: 'CADASTRAR',
                        isOutline: true,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey.shade300),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OU'),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey.shade300),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SocialButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        label: 'Continue with Apple',
                        icon: Icons.apple,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                child: const Text('Voltar para o inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onPressed: () {},
        icon: Icon(icon, color: AppColors.textPrimary),
        label: Text(label),
      ),
    );
  }
}
