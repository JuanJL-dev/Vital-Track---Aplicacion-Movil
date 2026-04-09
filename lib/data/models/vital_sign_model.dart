enum VitalType { heartRate, spo2, temperature, exercise, steps }

class VitalSign {
  final String id;
  final VitalType type;
  final double value;
  final double? secondaryValue;
  final DateTime timestamp;
  final bool isSimulated;

  VitalSign({
    required this.id,
    required this.type,
    required this.value,
    this.secondaryValue,
    required this.timestamp,
    this.isSimulated = false,
  });

  // UNIDADES TRADUCIDAS
  String get unit {
    switch (type) {
      case VitalType.heartRate:
        return 'lpm'; // latidos por minuto
      case VitalType.spo2:
        return '%';
      case VitalType.temperature:
        return '°C';
      case VitalType.exercise:
        return 'min';
      case VitalType.steps:
        return 'pasos';
    }
  }

  String get displayValue {
    switch (type) {
      case VitalType.heartRate:
      case VitalType.spo2:
      case VitalType.exercise:
      case VitalType.steps:
        return value.toStringAsFixed(0);
      case VitalType.temperature:
        return value.toStringAsFixed(1);
    }
  }

  // ESTADOS TRADUCIDOS AL ESPAÑOL
  String get status {
    switch (type) {
      case VitalType.heartRate:
        if (value < 60) return 'Bajo';
        if (value <= 100) return 'Normal';
        return 'Elevado';
      case VitalType.spo2:
        if (value >= 95) return 'Normal';
        return 'Hipoxia Leve';
      case VitalType.temperature:
        if (value < 36.0) return 'Hipotermia';
        if (value <= 37.5) return 'Normal';
        return 'Fiebre';
      case VitalType.exercise:
        if (value < 30) return 'Sedentario';
        if (value < 60) return 'Moderado';
        return 'Activo';
      case VitalType.steps:
        if (value < 5000) return 'Bajo';
        if (value < 10000) return 'Normal';
        return 'Activo';
    }
  }

  // MÉTODO PARA MOSTRAR EL NOMBRE DEL TIPO EN ESPAÑOL
  String get typeName {
    switch (type) {
      case VitalType.heartRate:
        return 'Ritmo Cardíaco';
      case VitalType.spo2:
        return 'Oxigenación (SpO2)';
      case VitalType.temperature:
        return 'Temperatura';
      case VitalType.exercise:
        return 'Ejercicio';
      case VitalType.steps:
        return 'Pasos';
    }
  }

  VitalSign copyWith({
    String? id,
    VitalType? type,
    double? value,
    double? secondaryValue,
    DateTime? timestamp,
    bool? isSimulated,
  }) {
    return VitalSign(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      timestamp: timestamp ?? this.timestamp,
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }

  static List<VitalSign> fromSupabase(Map<String, dynamic> json) {
    final String fechaStr = json['fecha_registro']?.toString() ?? '';
    final DateTime time =
        DateTime.tryParse(fechaStr)?.toLocal() ?? DateTime.now();
    final String rowId = json['id']?.toString() ?? '0';

    final double bpmValue =
        double.tryParse(json['bpm']?.toString() ?? '0') ?? 0.0;
    final double spo2Value =
        double.tryParse(json['spo2']?.toString() ?? '0') ?? 0.0;
    final double tempValue =
        double.tryParse(json['temperatura']?.toString() ?? '0') ?? 0.0;
    final double pasosValue =
        double.tryParse(json['pasos']?.toString() ?? '0') ?? 0.0;

    return [
      VitalSign(
        id: '${rowId}_bpm',
        type: VitalType.heartRate,
        value: bpmValue,
        timestamp: time,
      ),
      VitalSign(
        id: '${rowId}_spo2',
        type: VitalType.spo2,
        value: spo2Value,
        timestamp: time,
      ),
      VitalSign(
        id: '${rowId}_temp',
        type: VitalType.temperature,
        value: tempValue,
        timestamp: time,
      ),
      VitalSign(
        id: '${rowId}_steps',
        type: VitalType.steps,
        value: pasosValue,
        timestamp: time,
      ),
    ];
  }
}
