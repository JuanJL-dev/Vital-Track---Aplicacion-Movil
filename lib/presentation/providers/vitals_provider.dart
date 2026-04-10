import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/vital_sign_model.dart';
import '../../data/repositories/vitals_repository.dart';
import '../providers/auth_provider.dart';

class VitalsProvider extends ChangeNotifier {
  VitalsRepository? _repository;
  AuthProvider? _authProvider;

  // Variables actuales
  VitalSign? _heartRate;
  VitalSign? _spo2;
  VitalSign? _temperature;
  VitalSign? _exercise;
  VitalSign? _steps;

  // Historial de datos
  List<VitalSign> _heartRateHistory = [];
  List<VitalSign> _spo2History = [];
  List<VitalSign> _temperatureHistory = [];
  List<VitalSign> _exerciseHistory = [];
  List<VitalSign> _stepsHistory = [];

  bool _isMeasuring = false;
  bool _isLoadingHistory = false;
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
              _heartRateHistory.add(_heartRate!);
            }

            if (data['spo2'] != null) {
              _spo2 = VitalSign(
                id: safeId,
                type: VitalType.spo2,
                value: (data['spo2'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
              _spo2History.add(_spo2!);
            }

            if (data['temperatura'] != null) {
              _temperature = VitalSign(
                id: safeId,
                type: VitalType.temperature,
                value: (data['temperatura'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
              _temperatureHistory.add(_temperature!);
            }

            if (data['pasos'] != null) {
              _steps = VitalSign(
                id: safeId,
                type: VitalType.steps,
                value: (data['pasos'] as num).toDouble(),
                timestamp: safeTimestamp,
              );
              _stepsHistory.add(_steps!);
            }

            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> fetchHistoricalData(VitalType type, int days) async {
    if (_patientId == null) return;

    _isLoadingHistory = true;
    Future.microtask(() => notifyListeners());

    try {
      final supabase = Supabase.instance.client;
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final response = await supabase
          .from('signos_vitales')
          .select()
          .eq('paciente_id', _patientId!)
          .gte('fecha_registro', cutoffDate.toIso8601String())
          .order('fecha_registro', ascending: true);

      List<VitalSign> fetchedList = [];

      for (var data in response) {
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

        double? value;
        switch (type) {
          case VitalType.heartRate:
            value = data['bpm'] != null
                ? (data['bpm'] as num).toDouble()
                : null;
            break;
          case VitalType.spo2:
            value = data['spo2'] != null
                ? (data['spo2'] as num).toDouble()
                : null;
            break;
          case VitalType.temperature:
            value = data['temperatura'] != null
                ? (data['temperatura'] as num).toDouble()
                : null;
            break;
          case VitalType.steps:
            value = data['pasos'] != null
                ? (data['pasos'] as num).toDouble()
                : null;
            break;
          default:
            break;
        }

        if (value != null) {
          fetchedList.add(
            VitalSign(
              id: safeId,
              type: type,
              value: value,
              timestamp: safeTimestamp,
            ),
          );
        }
      }

      // AQUÍ: Asignamos el historial Y la última lectura como valor actual
      switch (type) {
        case VitalType.heartRate:
          _heartRateHistory = fetchedList;
          if (fetchedList.isNotEmpty) _heartRate = fetchedList.last;
          break;
        case VitalType.spo2:
          _spo2History = fetchedList;
          if (fetchedList.isNotEmpty) _spo2 = fetchedList.last;
          break;
        case VitalType.temperature:
          _temperatureHistory = fetchedList;
          if (fetchedList.isNotEmpty) _temperature = fetchedList.last;
          break;
        case VitalType.steps:
          _stepsHistory = fetchedList;
          if (fetchedList.isNotEmpty) _steps = fetchedList.last;
          break;
        default:
          break;
      }
    } catch (e) {
      if (kDebugMode) print("Error al obtener historial: $e");
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  bool isBpmAlert() {
    final user = _authProvider?.currentUser;
    if (user == null || _heartRate == null) return false;
    return _heartRate!.value > user.bpmMax || _heartRate!.value < user.bpmMin;
  }

  bool isSpo2Alert() {
    final user = _authProvider?.currentUser;
    if (user == null || _spo2 == null) return false;
    return _spo2!.value < user.spo2Min || _spo2!.value > 100;
  }

  bool isTempAlert() {
    final user = _authProvider?.currentUser;
    if (user == null || _temperature == null) return false;
    return _temperature!.value > user.tempMax ||
        _temperature!.value < user.tempMin;
  }

  String? get activeAlertMessage {
    final user = _authProvider?.currentUser;
    if (user == null) return null;

    List<String> warnings = [];

    if (isBpmAlert()) {
      if (_heartRate!.value > user.bpmMax)
        warnings.add('Taquicardia (${_heartRate!.value} lpm)');
      else
        warnings.add('Bradicardia (${_heartRate!.value} lpm)');
    }

    if (isSpo2Alert()) {
      if (_spo2!.value < user.spo2Min)
        warnings.add('Hipoxia (${_spo2!.value}%)');
      else if (_spo2!.value > 100)
        warnings.add('SpO₂ Anormal (${_spo2!.value}%)');
    }

    if (isTempAlert()) {
      if (_temperature!.value > user.tempMax)
        warnings.add('Fiebre (${_temperature!.value}°C)');
      else
        warnings.add('Hipotermia (${_temperature!.value}°C)');
    }

    if (warnings.isNotEmpty) return warnings.join(' | ');
    return null;
  }

  VitalSign? get heartRate => _heartRate;
  VitalSign? get spo2 => _spo2;
  VitalSign? get temperature => _temperature;
  VitalSign? get exercise => _exercise;
  VitalSign? get steps => _steps;

  bool get isMeasuring => _isMeasuring;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isInitialized => _initialized;

  String? get patientId {
    if (_patientId == null && _authProvider != null) {
      _syncPatientId();
    }
    return _patientId;
  }

  void setPatientId(String patientId) {
    if (_patientId != patientId) {
      _patientId = patientId;
      _setupRealtimeSubscription();
      notifyListeners();
    }
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

  void refreshData() {
    loadInitialData();
  }

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
