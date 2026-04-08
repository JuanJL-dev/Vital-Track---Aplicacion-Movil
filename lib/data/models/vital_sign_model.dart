enum VitalType { heartRate, bloodPressure, spo2, sleep, exercise, steps }

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

  String get unit {
    switch (type) {
      case VitalType.heartRate:
        return 'lpm';
      case VitalType.bloodPressure:
        return 'mmHg';
      case VitalType.spo2:
        return '%';
      case VitalType.sleep:
        return 'hrs';
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
      case VitalType.sleep:
      case VitalType.exercise:
      case VitalType.steps:
        return value.toStringAsFixed(0);
      case VitalType.bloodPressure:
        return '${value.toStringAsFixed(0)}/${secondaryValue?.toStringAsFixed(0) ?? ""}';
    }
  }

  String getStatus() {
    switch (type) {
      case VitalType.heartRate:
        if (value < 60) return 'Bajo';
        if (value <= 100) return 'Normal';
        return 'Elevado';
      case VitalType.bloodPressure:
        final systolic = value;
        final diastolic = secondaryValue ?? 80;
        if (systolic < 120 && diastolic < 80) return 'Normal';
        if (systolic < 140 && diastolic < 90) return 'Prehipertensión';
        if (systolic < 160 && diastolic < 100) return 'Hipertensión Etapa 1';
        return 'Hipertensión Etapa 2';
      case VitalType.spo2:
        if (value >= 95) return 'Normal';
        return 'Hipoxia Leve';
      case VitalType.sleep:
        if (value < 6) return 'Insuficiente';
        if (value < 7) return 'Suficiente';
        return 'Óptimo';
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
}
