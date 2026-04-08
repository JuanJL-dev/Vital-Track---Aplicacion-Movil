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
    required VitalSign bloodPressure,
    required VitalSign spo2,
    required VitalSign sleep,
    required VitalSign exercise,
    required VitalSign steps,
  }) async {
    try {
      await _supabaseService.insertVitalSigns(
        pacienteId: pacienteId,
        bpm: heartRate.value,
        spo2: spo2.value,
        pasos: steps.value.toInt(),
        presionSistolica: bloodPressure.value,
        presionDiastolica: bloodPressure.secondaryValue ?? 0,
        sueno: sleep.value,
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
        switch (type) {
          case VitalType.heartRate:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.heartRate,
              value: (item['bpm'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
              isSimulated: false,
            );
          case VitalType.bloodPressure:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.bloodPressure,
              value: (item['presion_sistolica'] as num?)?.toDouble() ?? 0,
              secondaryValue:
                  (item['presion_diastolica'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
              isSimulated: false,
            );
          case VitalType.spo2:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.spo2,
              value: (item['spo2'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
              isSimulated: false,
            );
          case VitalType.sleep:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.sleep,
              value: (item['sueno'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
              isSimulated: false,
            );
          case VitalType.exercise:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.exercise,
              value: (item['ejercicio_minutos'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
              isSimulated: false,
            );
          case VitalType.steps:
            return VitalSign(
              id: item['id'].toString(),
              type: VitalType.steps,
              value: (item['pasos'] as num?)?.toDouble() ?? 0,
              timestamp: DateTime.parse(item['fecha_registro'].toString()),
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
      case VitalType.bloodPressure:
        return _mockService.generateBloodPressure();
      case VitalType.spo2:
        return _mockService.generateSpO2();
      case VitalType.sleep:
        return _mockService.generateSleepData();
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
