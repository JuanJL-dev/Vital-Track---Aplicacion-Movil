import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/main_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTermsDialog;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  // --- TEXTO LEGAL INVENTADO ---
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Términos y Condiciones de VitalTrack',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última actualización: Abril 2026\n',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '1. ACEPTACIÓN DE LOS TÉRMINOS\n'
                    'Al utilizar VitalTrack, usted acepta cumplir con estos términos. Esta aplicación es una herramienta de monitoreo asistido y su acceso está restringido a usuarios registrados por personal médico autorizado.\n\n'
                    '2. NATURALEZA DEL SERVICIO\n'
                    'VitalTrack facilita el seguimiento de signos vitales (BPM, SpO2, Temperatura, Pasos). El sistema actúa como un puente de información entre el paciente y el profesional de la salud.\n\n'
                    '3. DESCARGO DE RESPONSABILIDAD MÉDICA\n'
                    'ESTA APLICACIÓN NO ES UN DISPOSITIVO DE EMERGENCIA. Si usted experimenta un síntoma grave, debe contactar a los servicios de emergencia locales inmediatamente. Los datos mostrados son referenciales y no sustituyen el diagnóstico de un médico presencial.\n\n'
                    '4. PRIVACIDAD Y SEGURIDAD\n'
                    'Sus datos biométricos son tratados bajo estrictos estándares de confidencialidad. Usted es responsable de mantener la seguridad de las credenciales de acceso proporcionadas por su clínica.\n\n'
                    '5. USO DE DATOS\n'
                    'La información recolectada será utilizada exclusivamente para el historial clínico del paciente y la mejora de su atención personalizada.\n\n'
                    '6. LIMITACIÓN DE RESPONSABILIDAD\n'
                    'VitalTrack no se hace responsable por fallos en la conectividad a internet o sensores externos que puedan alterar la precisión de los datos en tiempo real.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CERRAR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _acceptTerms = true);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('ACEPTAR'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, acepte los términos y condiciones para continuar.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.favorite, size: 80, color: AppTheme.primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acceso exclusivo para pacientes registrados por su centro médico.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Ingresa tu correo'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Ingresa tu contraseña'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // --- CHECKBOX CON ESTILO PROFESIONAL ---
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) =>
                              setState(() => _acceptTerms = value ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                            children: [
                              const TextSpan(text: 'He leído y acepto los '),
                              TextSpan(
                                text: 'Términos y condiciones',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' de VitalTrack.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ENTRAR AL SISTEMA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {}, // Lógica de recuperación
                    child: const Text('¿Problemas con sus credenciales?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
