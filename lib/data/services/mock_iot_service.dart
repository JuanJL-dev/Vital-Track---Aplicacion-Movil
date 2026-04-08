import '../models/vital_sign_model.dart';
import '../models/bluetooth_device_model.dart';
import '../../core/utils/random_walk_generator.dart';
import 'iot_service_interface.dart';

class MockIotService implements IIotService {
  RandomWalkGenerator? _randomWalkGenerator;

  RandomWalkGenerator get _rw {
    _randomWalkGenerator ??= RandomWalkGenerator();
    return _randomWalkGenerator!;
  }

  static final MockIotService _instance = MockIotService._internal();
  factory MockIotService() => _instance;
  MockIotService._internal();

  @override
  VitalSign generateHeartRate() {
    final value = _rw.generate(
      key: 'heartRate',
      min: 60.0,
      max: 100.0,
      volatility: 1.5,
      stepSize: 3.0,
    );

    return VitalSign(
      id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.heartRate,
      value: value,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  VitalSign generateBloodPressure() {
    final systolic = _rw.generate(
      key: 'systolic',
      min: 110.0,
      max: 130.0,
      volatility: 2.0,
      stepSize: 4.0,
    );

    final diastolic = _rw.generate(
      key: 'diastolic',
      min: 70.0,
      max: 85.0,
      volatility: 1.5,
      stepSize: 3.0,
    );

    return VitalSign(
      id: 'bp_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.bloodPressure,
      value: systolic,
      secondaryValue: diastolic,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  VitalSign generateSpO2() {
    final value = _rw.generate(
      key: 'spo2',
      min: 95.0,
      max: 100.0,
      volatility: 0.3,
      stepSize: 0.5,
    );

    return VitalSign(
      id: 'spo2_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.spo2,
      value: value,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  VitalSign generateSleepData() {
    final value = _rw.generate(
      key: 'sleep',
      min: 6.0,
      max: 8.5,
      volatility: 0.2,
      stepSize: 0.3,
    );

    return VitalSign(
      id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.sleep,
      value: value,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  VitalSign generateExerciseData() {
    final value = _rw.generate(
      key: 'exercise',
      min: 15.0,
      max: 90.0,
      volatility: 5.0,
      stepSize: 10.0,
    );

    return VitalSign(
      id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.exercise,
      value: value,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  VitalSign generateStepsData() {
    final value = _rw.generate(
      key: 'steps',
      min: 3000.0,
      max: 12000.0,
      volatility: 200.0,
      stepSize: 500.0,
    );

    return VitalSign(
      id: 'steps_${DateTime.now().millisecondsSinceEpoch}',
      type: VitalType.steps,
      value: value,
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }

  @override
  List<VitalSign> generateHistoricalData(VitalType type, int days) {
    final List<VitalSign> data = [];
    final now = DateTime.now();
    final hoursPerDay = type == VitalType.sleep ? 1 : 6;

    for (int day = days - 1; day >= 0; day--) {
      final date = now.subtract(Duration(days: day));

      for (int hourOffset = 0; hourOffset < hoursPerDay; hourOffset++) {
        final hour = (hourOffset * 4) % 24;
        final timestamp = DateTime(date.year, date.month, date.day, hour);

        final vital = _generateHistoricalVital(type, timestamp, day);
        if (vital != null) {
          data.add(vital);
        }
      }
    }

    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return data;
  }

  VitalSign? _generateHistoricalVital(
    VitalType type,
    DateTime timestamp,
    int daysAgo,
  ) {
    final String keySuffix = 'hist_${timestamp.millisecondsSinceEpoch}';

    switch (type) {
      case VitalType.heartRate:
        _rw.setInitialValue('hr_$keySuffix', 70.0);
        final value = _rw.generate(
          key: 'hr_$keySuffix',
          min: 55.0,
          max: 120.0,
          volatility: 2.0,
          stepSize: 5.0,
        );
        return VitalSign(
          id: 'hr_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: value,
          timestamp: timestamp,
          isSimulated: true,
        );

      case VitalType.bloodPressure:
        _rw.setInitialValue('sys_$keySuffix', 115.0);
        _rw.setInitialValue('dia_$keySuffix', 75.0);
        final systolic = _rw.generate(
          key: 'sys_$keySuffix',
          min: 100.0,
          max: 150.0,
          volatility: 3.0,
          stepSize: 6.0,
        );
        final diastolic = _rw.generate(
          key: 'dia_$keySuffix',
          min: 60.0,
          max: 100.0,
          volatility: 2.0,
          stepSize: 4.0,
        );
        return VitalSign(
          id: 'bp_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: systolic,
          secondaryValue: diastolic,
          timestamp: timestamp,
          isSimulated: true,
        );

      case VitalType.spo2:
        _rw.setInitialValue('spo2_$keySuffix', 97.0);
        final value = _rw.generate(
          key: 'spo2_$keySuffix',
          min: 92.0,
          max: 100.0,
          volatility: 0.5,
          stepSize: 1.0,
        );
        return VitalSign(
          id: 'spo2_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: value,
          timestamp: timestamp,
          isSimulated: true,
        );

      case VitalType.sleep:
        _rw.setInitialValue('sleep_$keySuffix', 7.0);
        final value = _rw.generate(
          key: 'sleep_$keySuffix',
          min: 4.0,
          max: 10.0,
          volatility: 0.3,
          stepSize: 0.5,
        );
        return VitalSign(
          id: 'sleep_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: value,
          timestamp: timestamp,
          isSimulated: true,
        );

      case VitalType.exercise:
        _rw.setInitialValue('exercise_$keySuffix', 45.0);
        final value = _rw.generate(
          key: 'exercise_$keySuffix',
          min: 0.0,
          max: 120.0,
          volatility: 8.0,
          stepSize: 15.0,
        );
        return VitalSign(
          id: 'exercise_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: value,
          timestamp: timestamp,
          isSimulated: true,
        );

      case VitalType.steps:
        _rw.setInitialValue('steps_$keySuffix', 7000.0);
        final value = _rw.generate(
          key: 'steps_$keySuffix',
          min: 1000.0,
          max: 15000.0,
          volatility: 300.0,
          stepSize: 600.0,
        );
        return VitalSign(
          id: 'steps_hist_${timestamp.millisecondsSinceEpoch}',
          type: type,
          value: value,
          timestamp: timestamp,
          isSimulated: true,
        );
    }
  }

  @override
  void resetRandomWalkState(VitalType type) {
    switch (type) {
      case VitalType.heartRate:
        _rw.reset('heartRate');
        break;
      case VitalType.bloodPressure:
        _rw.reset('systolic');
        _rw.reset('diastolic');
        break;
      case VitalType.spo2:
        _rw.reset('spo2');
        break;
      case VitalType.sleep:
        _rw.reset('sleep');
        break;
      case VitalType.exercise:
        _rw.reset('exercise');
        break;
      case VitalType.steps:
        _rw.reset('steps');
        break;
    }
  }

  @override
  List<BluetoothDevice> scanForDevices() {
    return [
      BluetoothDevice(
        id: 'device_1',
        name: 'VitalBand Pro',
        deviceId: 'VB-2024-001',
        batteryLevel: 85,
        status: DeviceConnectionStatus.disconnected,
      ),
      BluetoothDevice(
        id: 'device_2',
        name: 'VitalBand Lite',
        deviceId: 'VB-2024-002',
        batteryLevel: 62,
        status: DeviceConnectionStatus.disconnected,
      ),
      BluetoothDevice(
        id: 'device_3',
        name: 'HealthWatch X',
        deviceId: 'HW-2024-001',
        batteryLevel: 45,
        status: DeviceConnectionStatus.disconnected,
      ),
    ];
  }
}
