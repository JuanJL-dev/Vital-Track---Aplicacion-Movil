import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/login_screen.dart';
import 'subscreens/medical_record_screen.dart';
import 'subscreens/security_screen.dart';
import 'subscreens/support_screen.dart';
import 'subscreens/about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(
                  context,
                  user?.name ?? 'Usuario',
                  user?.email ?? '',
                ),
                const SizedBox(height: 24),
                _buildMedicalRecordSection(context),
                const SizedBox(height: 16),
                _buildDeviceSection(context),
                const SizedBox(height: 24),
                _buildSettingsSection(context, authProvider),
                const SizedBox(height: 24),
                _buildLogoutButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          label: 'Perfil de usuario: $name, correo: $email',
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar Información'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRecordSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expediente Médico',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Icon(Icons.lock, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.folder_shared,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Ver Expediente Completo'),
            subtitle: const Text(
              'Solo lectura',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicalRecordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(BuildContext context) {
    return Card(
      child: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Dispositivo Vinculado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: Icon(
                  deviceProvider.isConnected ? Icons.watch : Icons.watch_off,
                  color: deviceProvider.isConnected
                      ? AppTheme.successColor
                      : AppTheme.textDisabled,
                ),
                title: Semantics(
                  label: deviceProvider.isConnected
                      ? 'Dispositivo ${deviceProvider.connectedDevice?.name ?? "conectado"}'
                      : 'Sin dispositivo vinculado',
                  child: Text(
                    deviceProvider.isConnected
                        ? deviceProvider.connectedDevice?.name ?? 'Dispositivo'
                        : 'Sin dispositivo',
                  ),
                ),
                subtitle: Text(
                  deviceProvider.isConnected
                      ? 'Conectado'
                      : 'Toca para vincular',
                ),
                trailing: deviceProvider.isConnected
                    ? Text(
                        '${deviceProvider.connectedDevice?.batteryLevel ?? 0}%',
                        style: const TextStyle(color: AppTheme.successColor),
                      )
                    : null,
              ),
              if (deviceProvider.isConnected)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Desvincular Dispositivo'),
                          content: const Text(
                            '¿Estás seguro de que deseas desvincular este dispositivo?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Desvincular'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await deviceProvider.disconnectDevice();
                      }
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text('Desvincular'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return Semantics(
                label:
                    'Notificaciones: ${settingsProvider.notificationsEnabled ? "activadas" : "desactivadas"}',
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Notificaciones'),
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotificationsEnabled(value);
                  },
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            secondary: const Icon(Icons.brightness_6),
            value: context.watch<SettingsProvider>().darkModeEnabled,
            onChanged: (bool value) {
              // Usamos el método que ya tenías en tu archivo
              context.read<SettingsProvider>().setDarkModeEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Seguridad'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda y Soporte'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    final nameController = TextEditingController(
      text: user?.name.split(' ').first ?? '',
    );
    final lastNameController = TextEditingController(
      text: user?.name.split(' ').skip(1).join(' ') ?? '',
    );
    final phoneController = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Información'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName =
                  '${nameController.text} ${lastNameController.text}'.trim();
              await authProvider.updateUserName(newName);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Información actualizada')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
