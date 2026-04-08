import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda y Soporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Preguntas Frecuentes'),
            _buildFaqCard(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Contacto'),
            _buildContactCard(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Recursos'),
            _buildResourcesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar ayuda...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ExpansionTile(
            leading: const Icon(Icons.favorite, color: AppTheme.heartColor),
            title: const Text('¿Cómo mido mi frecuencia cardíaca?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Abre la aplicación, navega a la sección de Frecuencia Cardíaca y presiona el botón "Iniciar Medición". Asegúrate de tener tu dispositivo IoT conectado para obtener lecturas precisas.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.watch, color: AppTheme.primaryColor),
            title: const Text('¿Cómo vinculo mi dispositivo?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ve a Perfil > Dispositivo Vinculado y sigue las instrucciones para emparejar tu dispositivo por Bluetooth.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.share, color: AppTheme.primaryColor),
            title: const Text('¿Cómo comparto mis datos con mi médico?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tu médico puede acceder a tus datos automáticamente si está asignado a tu perfil. Para verificar, ve a Perfil > Expediente Médico.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.warning, color: AppTheme.warningColor),
            title: const Text('¿Qué hago si mis lecturas son anormales?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Las lecturas anormales se marcan con colores específicos. Si los valores persisten fuera de los rangos normales, te recomendamos consultar a tu médico.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: AppTheme.primaryColor),
            title: const Text('Correo Electrónico'),
            subtitle: const Text('soporte@vitaltrack.com'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _sendEmail(context),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
            title: const Text('Teléfono'),
            subtitle: const Text('+52 800 123 4567'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _makeCall(context),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
            title: const Text('Chat en Vivo'),
            subtitle: const Text('Disponible 24/7'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openChat(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book, color: AppTheme.primaryColor),
            title: const Text('Manual de Usuario'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openResource(context, 'Manual'),
          ),
          ListTile(
            leading: const Icon(
              Icons.video_library,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Tutoriales en Video'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openResource(context, 'Videos'),
          ),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openResource(context, 'Términos'),
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openResource(context, 'Privacidad'),
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo correo electrónico...')),
    );
  }

  void _makeCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Llamando al centro de soporte...')),
    );
  }

  void _openChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando chat de soporte...')),
    );
  }

  void _openResource(BuildContext context, String resource) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abriendo $resource...')));
  }
}
