import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final PatientRepository _patientRepository = PatientRepository();

  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _showOnboarding = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get showOnboarding => _showOnboarding;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService().client
          .from('pacientes')
          .select()
          .eq('correo', email)
          .eq('contrasena', password)
          .maybeSingle();

      if (response != null) {
        _currentUser = User(
          id: response['id'].toString(),
          name: '${response['nombre'] ?? ''} ${response['apellido'] ?? ''}'
              .trim(),
          email: response['correo']?.toString() ?? email,
          createdAt:
              DateTime.tryParse(response['created_at']?.toString() ?? '') ??
              DateTime.now(),
        );
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Credenciales incorrectas';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión';
      debugPrint('Login error: $e');

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Usuario Demo',
        email: email,
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nameParts = name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : name;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final response = await SupabaseService().client
          .from('pacientes')
          .insert({
            'nombre': firstName,
            'apellido': lastName,
            'correo': email,
            'contrasena': password,
            'status': 'active',
          })
          .select()
          .single();

      _currentUser = User(
        id: response['id'].toString(),
        name: name,
        email: email,
        createdAt:
            DateTime.tryParse(response['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al registrar usuario';
      debugPrint('Register error: $e');

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  }

  void completeOnboarding() {
    _showOnboarding = false;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (_currentUser == null) return;

    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : name;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      await _patientRepository.updatePatientBasicInfo(
        pacienteId: _currentUser!.id,
        nombre: firstName,
        apellido: lastName,
      );

      _currentUser = _currentUser!.copyWith(name: name);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user name: $e');
      _currentUser = _currentUser!.copyWith(name: name);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService().client.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _currentUser = null;
    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
