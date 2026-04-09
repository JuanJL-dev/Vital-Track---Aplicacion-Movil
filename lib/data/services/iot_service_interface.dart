import '../models/vital_sign_model.dart';
import '../models/bluetooth_device_model.dart';

abstract class IIotService {
  VitalSign generateHeartRate();
  VitalSign generateTemperature(); // Solo una vez
  VitalSign generateSpO2();
  VitalSign generateExerciseData();
  VitalSign generateStepsData();
  List<VitalSign> generateHistoricalData(VitalType type, int days);
  List<BluetoothDevice> scanForDevices();
  void resetRandomWalkState(VitalType type);
}
