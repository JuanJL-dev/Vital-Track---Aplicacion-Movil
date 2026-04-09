import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static bool _initialized = false;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'SupabaseService no ha sido inicializado. Llama a SupabaseService.initialize() primero.',
      );
    }
    return Supabase.instance.client;
  }

  // AQUÍ ESTÁ EL CAMBIO FINAL: Eliminamos presión y sueño, y agregamos la Temperatura
  Future<Map<String, dynamic>> insertVitalSigns({
    required String pacienteId,
    required int bpm,
    required int spo2,
    required int pasos,
    required double temperatura, // NUEVO
    required int ejercicioMinutos,
  }) async {
    return await client
        .from('signos_vitales')
        .insert({
          'paciente_id': pacienteId,
          'bpm': bpm,
          'spo2': spo2,
          'pasos': pasos,
          'temperatura':
              temperatura, // NUEVO: Se guarda en la columna "temperatura" de Supabase
          'ejercicio_minutos': ejercicioMinutos,
          // Eliminamos fecha_registro del insert porque Supabase lo hace en automático con "default now()"
        })
        .select()
        .single();
  }

  Future<Map<String, dynamic>> getPatientById(String pacienteId) async {
    return await client
        .from('pacientes')
        .select()
        .eq('id', pacienteId)
        .single();
  }

  Future<List<Map<String, dynamic>>> updatePatientBasicInfo({
    required String pacienteId,
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    final updates = <String, dynamic>{};
    if (nombre != null) updates['nombre'] = nombre;
    if (apellido != null) updates['apellido'] = apellido;
    if (telefono != null) updates['telefono'] = telefono;

    return await client
        .from('pacientes')
        .update(updates)
        .eq('id', pacienteId)
        .select();
  }

  Future<List<Map<String, dynamic>>> getVitalSignsHistory({
    required String pacienteId,
    required int limit,
  }) async {
    return await client
        .from('signos_vitales')
        .select()
        .eq('paciente_id', pacienteId)
        .order('fecha_registro', ascending: false)
        .limit(limit);
  }

  Future<Map<String, dynamic>> getMedicalRecord(String pacienteId) async {
    return await client
        .from('pacientes')
        .select(
          'id, nombre, apellido, genero, edad, domicilio, telefono, correo, status, doctor_id, created_at, bpm_min, bpm_max, spo2_min, temp_min, temp_max',
        )
        .eq('id', pacienteId)
        .single();
  }

  Future<Map<String, dynamic>> getAssignedDoctor(String doctorId) async {
    return await client.from('medicos').select().eq('id', doctorId).single();
  }
}
