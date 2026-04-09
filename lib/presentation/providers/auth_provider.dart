import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/vital_sign_model.dart';

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
      if (!SupabaseService.isInitialized) {
        _isLoading = false;
        _errorMessage = 'Servicio de autenticación no disponible';
        notifyListeners();
        return false;
      }

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
      _errorMessage = 'Error de conexión: ${e.toString()}';
      debugPrint('Login error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!SupabaseService.isInitialized) {
        _isLoading = false;
        _errorMessage = 'Servicio de autenticación no disponible';
        notifyListeners();
        return false;
      }

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
      _errorMessage = 'Error al registrar usuario: ${e.toString()}';
      debugPrint('Register error: $e');
      notifyListeners();
      return false;
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
      if (SupabaseService.isInitialized) {
        await SupabaseService().client.auth.signOut();
      }
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

  // --- MÉTODOS DE CONSULTA DE DATOS ---

  Future<List<VitalSign>> getPatientHistory() async {
    if (_currentUser == null) return [];

    try {
      final response = await SupabaseService().client
          .from('signos_vitales')
          .select()
          .eq('paciente_id', _currentUser!.id)
          .order('fecha_registro', ascending: false)
          .limit(20);

      List<VitalSign> allVitals = [];
      final List data = response as List;

      for (var row in data) {
        try {
          allVitals.addAll(VitalSign.fromSupabase(row));
        } catch (e) {
          // Registro silencioso del error para no saturar la consola,
          // pero útil por si un dato llega corrupto.
          debugPrint(
            'Aviso: Se omitió un registro corrupto (ID: ${row['id']}). Error: $e',
          );
        }
      }

      return allVitals;
    } catch (e) {
      debugPrint('Error general consultando el historial: $e');
      return [];
    }
  }

  Future<void> refreshPacientConfig() async {
    if (_currentUser == null) return;

    try {
      final response = await SupabaseService().client
          .from('pacientes')
          .select('bpm_min, bpm_max, spo2_min, temp_min, temp_max')
          .eq('id', _currentUser!.id)
          .single();

      if (response != null) {
        // Actualizamos solo los rangos del usuario actual
        _currentUser = _currentUser!.copyWith(
          bpmMin: (response['bpm_min'] as num?)?.toDouble() ?? 60.0,
          bpmMax: (response['bpm_max'] as num?)?.toDouble() ?? 100.0,
          spo2Min: (response['spo2_min'] as num?)?.toDouble() ?? 90.0,
          tempMin: (response['temp_min'] as num?)?.toDouble() ?? 36.0,
          tempMax: (response['temp_max'] as num?)?.toDouble() ?? 37.5,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al refrescar configuración: $e');
    }
  }
}
