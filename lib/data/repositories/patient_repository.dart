import '../models/patient_model.dart';
import '../services/supabase_service.dart';

class PatientRepository {
  final SupabaseService _supabaseService;

  PatientRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  Future<Patient?> getPatientById(String pacienteId) async {
    try {
      final response = await _supabaseService.getPatientById(pacienteId);
      return Patient.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Patient?> getMedicalRecord(String pacienteId) async {
    try {
      final response = await _supabaseService.getMedicalRecord(pacienteId);
      return Patient.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePatientBasicInfo({
    required String pacienteId,
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    try {
      await _supabaseService.updatePatientBasicInfo(
        pacienteId: pacienteId,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<DoctorInfo?> getAssignedDoctor(String doctorId) async {
    try {
      final response = await _supabaseService.getAssignedDoctor(doctorId);
      return DoctorInfo(
        id: response['id']?.toString() ?? '',
        name: response['nombre']?.toString() ?? '',
        avatarUrl: response['avatar_url']?.toString(),
        noMedico: response['no_medico']?.toString(),
      );
    } catch (e) {
      return null;
    }
  }
}

class DoctorInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? noMedico;

  DoctorInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.noMedico,
  });
}
