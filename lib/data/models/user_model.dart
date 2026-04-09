class User {
  final String id;
  final String name;
  final String email;
  final DateTime? birthDate;
  final String? gender;
  final double? height;
  final double? weight;
  final bool notificationsEnabled;
  final bool termsAccepted;
  final DateTime createdAt;

  // Campos de rangos configurados
  final double bpmMin;
  final double bpmMax;
  final double spo2Min;
  final double tempMin;
  final double tempMax;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.gender,
    this.height,
    this.weight,
    this.notificationsEnabled = true,
    this.termsAccepted = false,
    required this.createdAt,
    this.bpmMin = 60,
    this.bpmMax = 100,
    this.spo2Min = 90,
    this.tempMin = 36,
    this.tempMax = 37.5,
  });

  // --- COPIA Y PEGA DESDE AQUÍ ---

  /// Este método es el que evita el error de la pantalla roja.
  /// Si un valor viene nulo de la base de datos, le asigna el valor por defecto.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'])
          : null,
      gender: map['gender'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      termsAccepted: map['termsAccepted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),

      // Manejo de nulos para los rangos (La solución al error)
      bpmMin: (map['bpmMin'] ?? 60.0).toDouble(),
      bpmMax: (map['bpmMax'] ?? 100.0).toDouble(),
      spo2Min: (map['spo2Min'] ?? 90.0).toDouble(),
      tempMin: (map['tempMin'] ?? 36.0).toDouble(),
      tempMax: (map['tempMax'] ?? 37.5).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'notificationsEnabled': notificationsEnabled,
      'termsAccepted': termsAccepted,
      'createdAt': createdAt.toIso8601String(),
      'bpmMin': bpmMin,
      'bpmMax': bpmMax,
      'spo2Min': spo2Min,
      'tempMin': tempMin,
      'tempMax': tempMax,
    };
  }

  // --- HASTA AQUÍ ---

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? birthDate,
    String? gender,
    double? height,
    double? weight,
    bool? notificationsEnabled,
    bool? termsAccepted,
    DateTime? createdAt,
    double? bpmMin,
    double? bpmMax,
    double? spo2Min,
    double? tempMin,
    double? tempMax,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      createdAt: createdAt ?? this.createdAt,
      bpmMin: bpmMin ?? this.bpmMin,
      bpmMax: bpmMax ?? this.bpmMax,
      spo2Min: spo2Min ?? this.spo2Min,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
    );
  }
}
