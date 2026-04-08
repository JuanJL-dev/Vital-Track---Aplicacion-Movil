import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/vital_sign_model.dart';
import '../../data/repositories/vitals_repository.dart';

class VitalsProvider extends ChangeNotifier {
  VitalsRepository? _repository;

  VitalSign? _heartRate;
  VitalSign? _bloodPressure;
  VitalSign? _spo2;
  VitalSign? _sleep;
  VitalSign? _exercise;
  VitalSign? _steps;

  List<VitalSign> _heartRateHistory = [];
  List<VitalSign> _bloodPressureHistory = [];
  List<VitalSign> _spo2History = [];
  List<VitalSign> _sleepHistory = [];
  List<VitalSign> _exerciseHistory = [];
  List<VitalSign> _stepsHistory = [];

  bool _isMeasuring = false;
  String? _patientId;
  bool _initialized = false;

  VitalsProvider() {
    _repository = VitalsRepository();
  }

  VitalSign? get heartRate => _heartRate;
  VitalSign? get bloodPressure => _bloodPressure;
  VitalSign? get spo2 => _spo2;
  VitalSign? get sleep => _sleep;
  VitalSign? get exercise => _exercise;
  VitalSign? get steps => _steps;

  List<VitalSign> get heartRateHistory => _heartRateHistory;
  List<VitalSign> get bloodPressureHistory => _bloodPressureHistory;
  List<VitalSign> get spo2History => _spo2History;
  List<VitalSign> get sleepHistory => _sleepHistory;
  List<VitalSign> get exerciseHistory => _exerciseHistory;
  List<VitalSign> get stepsHistory => _stepsHistory;

  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _initialized;

  void setPatientId(String patientId) {
    _patientId = patientId;
    notifyListeners();
  }

  void loadInitialData() {
    if (_repository == null) {
      _repository = VitalsRepository();
    }

    _repository!.resetMockState(VitalType.heartRate);
    _repository!.resetMockState(VitalType.bloodPressure);
    _repository!.resetMockState(VitalType.spo2);
    _repository!.resetMockState(VitalType.sleep);
    _repository!.resetMockState(VitalType.exercise);
    _repository!.resetMockState(VitalType.steps);

    _heartRate = _repository!.generateMockVitalSign(VitalType.heartRate);
    _bloodPressure = _repository!.generateMockVitalSign(
      VitalType.bloodPressure,
    );
    _spo2 = _repository!.generateMockVitalSign(VitalType.spo2);
    _sleep = _repository!.generateMockVitalSign(VitalType.sleep);
    _exercise = _repository!.generateMockVitalSign(VitalType.exercise);
    _steps = _repository!.generateMockVitalSign(VitalType.steps);

    _heartRateHistory = _repository!.generateMockHistoricalData(
      VitalType.heartRate,
      7,
    );
    _bloodPressureHistory = _repository!.generateMockHistoricalData(
      VitalType.bloodPressure,
      7,
    );
    _spo2History = _repository!.generateMockHistoricalData(VitalType.spo2, 7);
    _sleepHistory = _repository!.generateMockHistoricalData(VitalType.sleep, 7);
    _exerciseHistory = _repository!.generateMockHistoricalData(
      VitalType.exercise,
      7,
    );
    _stepsHistory = _repository!.generateMockHistoricalData(VitalType.steps, 7);

    _initialized = true;
    notifyListeners();
  }

  Future<void> startMeasurement(VitalType type) async {
    if (_repository == null) return;

    _isMeasuring = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));

    switch (type) {
      case VitalType.heartRate:
        _heartRate = _repository!.generateMockVitalSign(VitalType.heartRate);
        break;
      case VitalType.bloodPressure:
        _bloodPressure = _repository!.generateMockVitalSign(
          VitalType.bloodPressure,
        );
        break;
      case VitalType.spo2:
        _spo2 = _repository!.generateMockVitalSign(VitalType.spo2);
        break;
      case VitalType.sleep:
        _sleep = _repository!.generateMockVitalSign(VitalType.sleep);
        break;
      case VitalType.exercise:
        _exercise = _repository!.generateMockVitalSign(VitalType.exercise);
        break;
      case VitalType.steps:
        _steps = _repository!.generateMockVitalSign(VitalType.steps);
        break;
    }

    if (_patientId != null && _heartRate != null) {
      await _saveToDatabase();
    }

    _isMeasuring = false;
    notifyListeners();
  }

  Future<void> _saveToDatabase() async {
    if (_patientId == null || _repository == null) return;

    try {
      await _repository!.saveVitalSigns(
        pacienteId: _patientId!,
        heartRate: _heartRate!,
        bloodPressure: _bloodPressure!,
        spo2: _spo2!,
        sleep: _sleep!,
        exercise: _exercise!,
        steps: _steps!,
      );
    } catch (e) {
      debugPrint('Error saving vital signs: $e');
    }
  }

  void refreshData() {
    loadInitialData();
  }

  List<VitalSign> getHistoricalData(VitalType type, int days) {
    if (_repository == null) return [];
    return _repository!.generateMockHistoricalData(type, days);
  }

  VitalSign? getCurrentVital(VitalType type) {
    switch (type) {
      case VitalType.heartRate:
        return _heartRate;
      case VitalType.bloodPressure:
        return _bloodPressure;
      case VitalType.spo2:
        return _spo2;
      case VitalType.sleep:
        return _sleep;
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
      case VitalType.bloodPressure:
        return _bloodPressureHistory;
      case VitalType.spo2:
        return _spo2History;
      case VitalType.sleep:
        return _sleepHistory;
      case VitalType.exercise:
        return _exerciseHistory;
      case VitalType.steps:
        return _stepsHistory;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
