class Patient {
  final String id;
  final String nombre;
  final String apellido;
  final String? genero;
  final int? edad;
  final String? domicilio;
  final String? telefono;
  final String? correo;
  final String? status;
  final String? doctorId;
  final DateTime? createdAt;

  final int? bpmMin;
  final int? bpmMax;
  final int? spo2Min;
  final int? tempMin;
  final int? tempMax;

  Patient({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.genero,
    this.edad,
    this.domicilio,
    this.telefono,
    this.correo,
    this.status,
    this.doctorId,
    this.createdAt,
    this.bpmMin,
    this.bpmMax,
    this.spo2Min,
    this.tempMin,
    this.tempMax,
  });

  String get fullName => '$nombre $apellido';

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      genero: json['genero']?.toString(),
      edad: json['edad'] is int
          ? json['edad']
          : int.tryParse(json['edad']?.toString() ?? ''),
      domicilio: json['domicilio']?.toString(),
      telefono: json['telefono']?.toString(),
      correo: json['correo']?.toString(),
      status: json['status']?.toString(),
      doctorId: json['doctor_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      bpmMin: json['bpm_min'] is int
          ? json['bpm_min']
          : int.tryParse(json['bpm_min']?.toString() ?? ''),
      bpmMax: json['bpm_max'] is int
          ? json['bpm_max']
          : int.tryParse(json['bpm_max']?.toString() ?? ''),
      spo2Min: json['spo2_min'] is int
          ? json['spo2_min']
          : int.tryParse(json['spo2_min']?.toString() ?? ''),
      tempMin: json['temp_min'] is int
          ? json['temp_min']
          : int.tryParse(json['temp_min']?.toString() ?? ''),
      tempMax: json['temp_max'] is int
          ? json['temp_max']
          : int.tryParse(json['temp_max']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'genero': genero,
      'edad': edad,
      'domicilio': domicilio,
      'telefono': telefono,
      'correo': correo,
      'status': status,
      'doctor_id': doctorId,
      'created_at': createdAt?.toIso8601String(),
      'bpm_min': bpmMin,
      'bpm_max': bpmMax,
      'spo2_min': spo2Min,
      'temp_min': tempMin,
      'temp_max': tempMax,
    };
  }

  Patient copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? genero,
    int? edad,
    String? domicilio,
    String? telefono,
    String? correo,
    String? status,
    String? doctorId,
    DateTime? createdAt,
    int? bpmMin,
    int? bpmMax,
    int? spo2Min,
    int? tempMin,
    int? tempMax,
  }) {
    return Patient(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      genero: genero ?? this.genero,
      edad: edad ?? this.edad,
      domicilio: domicilio ?? this.domicilio,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      status: status ?? this.status,
      doctorId: doctorId ?? this.doctorId,
      createdAt: createdAt ?? this.createdAt,
      bpmMin: bpmMin ?? this.bpmMin,
      bpmMax: bpmMax ?? this.bpmMax,
      spo2Min: spo2Min ?? this.spo2Min,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
    );
  }
}
