import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _buildAppIcon(context),
            const SizedBox(height: 24),
            _buildAppInfo(context),
            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),
            _buildDescription(context),
            const SizedBox(height: 32),
            _buildLinks(context),
            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildLegalInfo(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.favorite_rounded, size: 50, color: Colors.white),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'VitalTrack',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Versión 1.0.0',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          'Build 2024.04.07',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textDisabled),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.textSecondary.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'VitalTrack es una aplicación de monitoreo de salud diseñada para ayudarte a llevar un registro integral de tus signos vitales y actividad física. Conectada a dispositivos IoT, te permite visualizar tu estado de salud en tiempo real.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLinks(BuildContext context) {
    return Column(
      children: [
        _buildLinkItem(
          context,
          icon: Icons.language,
          title: 'Sitio Web',
          subtitle: 'www.vitaltrack.com',
        ),
        _buildLinkItem(
          context,
          icon: Icons.privacy_tip,
          title: 'Política de Privacidad',
          subtitle: 'Cómo protegemos tus datos',
        ),
        _buildLinkItem(
          context,
          icon: Icons.description,
          title: 'Términos de Servicio',
          subtitle: 'Condiciones de uso',
        ),
        _buildLinkItem(
          context,
          icon: Icons.article,
          title: 'Licencias de Código Abierto',
          subtitle: 'Librerías utilizadas',
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Abriendo $title...')));
        },
      ),
    );
  }

  Widget _buildLegalInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          '© 2024 VitalTrack Health Technologies',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textDisabled),
        ),
        const SizedBox(height: 8),
        Text(
          'Todos los derechos reservados',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textDisabled),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.facebook),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.photo_camera),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.alternate_email),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: AppTheme.textSecondary, size: 20),
    );
  }
}
