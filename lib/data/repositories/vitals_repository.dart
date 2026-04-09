import '../models/vital_sign_model.dart';
import '../services/supabase_service.dart';
import '../services/mock_iot_service.dart';

class VitalsRepository {
  final SupabaseService _supabaseService;
  final MockIotService _mockService;

  VitalsRepository({
    SupabaseService? supabaseService,
    MockIotService? mockService,
  }) : _supabaseService = supabaseService ?? SupabaseService(),
       _mockService = mockService ?? MockIotService();

  Future<void> saveVitalSigns({
    required String pacienteId,
    required VitalSign heartRate,
    required VitalSign temperature, // NUEVO: Reemplaza a presión y sueño
    required VitalSign spo2,
    required VitalSign exercise,
    required VitalSign steps,
  }) async {
    try {
      await _supabaseService.insertVitalSigns(
        pacienteId: pacienteId,
        bpm: heartRate.value.toInt(),
        spo2: spo2.value.toInt(),
        pasos: steps.value.toInt(),
        temperatura: temperature.value, // NUEVO: Guardando temperatura
        ejercicioMinutos: exercise.value.toInt(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VitalSign>> getVitalSignsHistory({
    required String pacienteId,
    required VitalType type,
    required int days,
  }) async {
    try {
      final response = await _supabaseService.getVitalSignsHistory(
        pacienteId: pacienteId,
        limit: days * 6,
      );

      return response.map((item) {
        // Aprovechamos para usar nuestra fecha segura anti-crasheos
        DateTime safeTimestamp = DateTime.now();
        if (item['fecha_registro'] != null) {
          safeTimestamp =
              DateTime.tryParse(item['fecha_registro'].toString()) ??
              DateTime.now();
        } else if (item['created_at'] != null) {
          safeTimestamp =
              DateTime.tryParse(item['created_at'].toString()) ??
              DateTime.now();
        }

        switch (type) {
          case VitalType.heartRate:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.heartRate,
              value: (item['bpm'] as num?)?.toDouble() ?? 0,
              timestamp: safeTimestamp,
              isSimulated: false,
            );
          case VitalType.temperature: // NUEVO
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.temperature,
              value: (item['temperatura'] as num?)?.toDouble() ?? 0,
              timestamp: safeTimestamp,
              isSimulated: false,
            );
          case VitalType.spo2:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.spo2,
              value: (item['spo2'] as num?)?.toDouble() ?? 0,
              timestamp: safeTimestamp,
              isSimulated: false,
            );
          case VitalType.exercise:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.exercise,
              value: (item['ejercicio_minutos'] as num?)?.toDouble() ?? 0,
              timestamp: safeTimestamp,
              isSimulated: false,
            );
          case VitalType.steps:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.steps,
              value: (item['pasos'] as num?)?.toDouble() ?? 0,
              timestamp: safeTimestamp,
              isSimulated: false,
            );
        }
      }).toList();
    } catch (e) {
      return _mockService.generateHistoricalData(type, days);
    }
  }

  VitalSign generateMockVitalSign(VitalType type) {
    switch (type) {
      case VitalType.heartRate:
        return _mockService.generateHeartRate();
      case VitalType.temperature: // NUEVO
        return _mockService.generateTemperature();
      case VitalType.spo2:
        return _mockService.generateSpO2();
      case VitalType.exercise:
        return _mockService.generateExerciseData();
      case VitalType.steps:
        return _mockService.generateStepsData();
    }
  }

  List<VitalSign> generateMockHistoricalData(VitalType type, int days) {
    return _mockService.generateHistoricalData(type, days);
  }

  void resetMockState(VitalType type) {
    _mockService.resetRandomWalkState(type);
  }
}
