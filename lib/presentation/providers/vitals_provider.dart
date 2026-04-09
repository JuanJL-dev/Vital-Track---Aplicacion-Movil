import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/vital_sign_model.dart';
import '../../data/repositories/vitals_repository.dart';
import '../../data/services/supabase_service.dart';
import '../providers/auth_provider.dart';

class VitalsProvider extends ChangeNotifier {
  VitalsRepository? _repository;
  AuthProvider? _authProvider;

  // 1. Variables actualizadas (Adios presión y sueño, hola temperatura)
  VitalSign? _heartRate;
  VitalSign? _spo2;
  VitalSign? _temperature;
  VitalSign? _exercise;
  VitalSign? _steps;

  List<VitalSign> _heartRateHistory = [];
  List<VitalSign> _spo2History = [];
  List<VitalSign> _temperatureHistory = [];
  List<VitalSign> _exerciseHistory = [];
  List<VitalSign> _stepsHistory = [];

  bool _isMeasuring = false;
  String? _patientId;
  bool _initialized = false;

  RealtimeChannel? _vitalsSubscription;

  VitalsProvider() {
    _repository = VitalsRepository();
  }

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _syncPatientId();
  }

  void _syncPatientId() {
    if (_authProvider != null && _authProvider!.currentUser != null) {
      final newPatientId = _authProvider!.currentUser!.id;
      if (_patientId != newPatientId) {
        _patientId = newPatientId;
        _setupRealtimeSubscription();
        notifyListeners();
      }
    }
  }

  void _setupRealtimeSubscription() {
    if (_patientId == null) return;

    _vitalsSubscription?.unsubscribe();

    final supabase = Supabase.instance.client;

    _vitalsSubscription = supabase
        .channel('public:signos_vitales')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'signos_vitales',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'paciente_id',
            value: _patientId!,
          ),
          callback: (PostgresChangePayload payload) {
            final data = payload.newRecord;

            DateTime safeTimestamp = DateTime.now();
            if (data['fecha_registro'] != null) {
              safeTimestamp =
                  DateTime.tryParse(data['fecha_registro'].toString()) ??
                  DateTime.now();
            } else if (data['created_at'] != null) {
              safeTimestamp =
                  DateTime.tryParse(data['created_at'].toString()) ??
                  DateTime.now();
            }

            String safeId =
                data['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString();

            if (data['bpm'] != null) {
              _heartRate = VitalSign(
                id: safeId,
                type: VitalType.heartRate,
                value: (data['bpm'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
            }

            if (data['spo2'] != null) {
              _spo2 = VitalSign(
                id: safeId,
                type: VitalType.spo2,
                value: (data['spo2'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
            }

            // 2. NUEVO: Leer la temperatura que manda el simulador
            if (data['temperatura'] != null) {
              _temperature = VitalSign(
                id: safeId,
                type: VitalType.temperature,
                value: (data['temperatura'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
            }

            if (data['pasos'] != null) {
              _steps = VitalSign(
                id: safeId,
                type: VitalType.steps,
                value: (data['pasos'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
            }

            notifyListeners();
          },
        )
        .subscribe();
  }

  // 3. Getters actualizados
  VitalSign? get heartRate => _heartRate;
  VitalSign? get spo2 => _spo2;
  VitalSign? get temperature => _temperature;
  VitalSign? get exercise => _exercise;
  VitalSign? get steps => _steps;

  List<VitalSign> get heartRateHistory => _heartRateHistory;
  List<VitalSign> get spo2History => _spo2History;
  List<VitalSign> get temperatureHistory => _temperatureHistory;
  List<VitalSign> get exerciseHistory => _exerciseHistory;
  List<VitalSign> get stepsHistory => _stepsHistory;

  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _initialized;

  void setPatientId(String patientId) {
    if (_patientId != patientId) {
      _patientId = patientId;
      _setupRealtimeSubscription();
      notifyListeners();
    }
  }

  String? get patientId {
    if (_patientId == null && _authProvider != null) {
      _syncPatientId();
    }
    return _patientId;
  }

  void loadInitialData() {
    _syncPatientId();
    if (_repository == null) {
      _repository = VitalsRepository();
    }
    _initialized = true;
    notifyListeners();
    _setupRealtimeSubscription();
  }

  Future<void> startMeasurement(VitalType type) async {
    _isMeasuring = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    _isMeasuring = false;
    notifyListeners();
  }

  void refreshData() {
    loadInitialData();
  }

  List<VitalSign> getHistoricalData(VitalType type, int days) {
    if (_repository == null) return [];
    return _repository!.generateMockHistoricalData(type, days);
  }

  // 4. Actualización de Switch Cases (Reemplazo de BP/Sleep por Temperature)
  VitalSign? getCurrentVital(VitalType type) {
    switch (type) {
      case VitalType.heartRate:
        return _heartRate;
      case VitalType.spo2:
        return _spo2;
      case VitalType.temperature:
        return _temperature;
      case VitalType.exercise:
        return _exercise;
      case VitalType.steps:
        return _steps;
    }
  }

  List<VitalSign> getHistoryForType(VitalType type) {
    switch (type) {
      case VitalType.heartRate:
        return _heartRateHistory;
      case VitalType.spo2:
        return _spo2History;
      case VitalType.temperature:
        return _temperatureHistory;
      case VitalType.exercise:
        return _exerciseHistory;
      case VitalType.steps:
        return _stepsHistory;
    }
  }

  @override
  void dispose() {
    _vitalsSubscription?.unsubscribe();
    super.dispose();
  }
}
