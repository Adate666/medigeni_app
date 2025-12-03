enum AppointmentStatus {
  pending,
  accepted,
  completed,
  rejected,
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime dateTime;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? notes;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.dateTime,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    DateTime? dateTime,
    String? reason,
    AppointmentStatus? status,
    DateTime? createdAt,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      dateTime: dateTime ?? this.dateTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientEmail: json['patientEmail'] as String,
      patientPhone: json['patientPhone'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      reason: json['reason'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }
}

