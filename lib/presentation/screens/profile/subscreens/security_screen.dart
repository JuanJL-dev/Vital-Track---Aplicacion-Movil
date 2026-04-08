import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _sessionAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Autenticación'),
            _buildSecurityCard([
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Autenticación Biométrica'),
                subtitle: const Text('Usar huella o Face ID'),
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.verified_user),
                title: const Text('Verificación en Dos Pasos'),
                subtitle: const Text('Capa adicional de seguridad'),
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Sesión'),
            _buildSecurityCard([
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Alertas de Sesión'),
                subtitle: const Text('Notificar nuevos inicios de sesión'),
                value: _sessionAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _sessionAlertsEnabled = value;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Dispositivos Conectados'),
                subtitle: const Text('Ver y gestionar dispositivos'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDevicesDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Historial de Ubicaciones'),
                subtitle: const Text('Ver accesos recientes'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLocationsDialog(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Contraseña'),
            _buildSecurityCard([
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Cambiar Contraseña'),
                subtitle: const Text('Actualiza tu contraseña'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showChangePasswordDialog(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildSecurityCard(List<Widget> children) {
    return Card(child: Column(children: children));
  }

  Widget _buildDangerZone() {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Zona de Peligro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever,
              color: AppTheme.errorColor,
            ),
            title: const Text(
              'Eliminar Cuenta',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            subtitle: const Text('Esta acción es irreversible'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispositivos Conectados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('iPhone 15 Pro'),
              subtitle: const Text('Activo ahora'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Eliminar'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tablet),
              title: const Text('iPad Pro'),
              subtitle: const Text('Último acceso: hace 2 días'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Eliminar'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLocationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de Ubicaciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Ciudad de México, MX'),
              subtitle: const Text('Hoy, 10:30 AM'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Guadalajara, MX'),
              subtitle: const Text('Ayer, 8:15 PM'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña Actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña actualizada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          'Esta acción eliminará permanentemente tu cuenta y todos tus datos. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cuenta eliminada')));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
