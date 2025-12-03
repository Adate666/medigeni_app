class BMIData {
  final String id;
  final String userId;
  final double weight; // en kg
  final double height; // en m
  final double bmi;
  final DateTime date;
  final String? aiInterpretation;
  final String? aiAdvice;

  BMIData({
    required this.id,
    required this.userId,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.date,
    this.aiInterpretation,
    this.aiAdvice,
  });

  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / (height * height);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'date': date.toIso8601String(),
      'aiInterpretation': aiInterpretation,
      'aiAdvice': aiAdvice,
    };
  }

  factory BMIData.fromJson(Map<String, dynamic> json) {
    return BMIData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      aiInterpretation: json['aiInterpretation'] as String?,
      aiAdvice: json['aiAdvice'] as String?,
    );
  }
}

class PeriodData {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength; // en jours
  final int periodLength; // en jours
  final String? notes;
  final List<String>? symptoms;

  PeriodData({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodLength,
    this.notes,
    this.symptoms,
  });

  DateTime? getNextPeriodDate() {
    return startDate.add(Duration(days: cycleLength));
  }

  bool isActive() {
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'notes': notes,
      'symptoms': symptoms,
    };
  }

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      cycleLength: json['cycleLength'] as int,
      periodLength: json['periodLength'] as int,
      notes: json['notes'] as String?,
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'] as List)
          : null,
    );
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class SymptomAnalysis {
  final String id;
  final String userId;
  final List<String> symptoms;
  final String severity; // low, medium, high, emergency
  final String? possibleCauses;
  final String? immediateAdvice;
  final DateTime date;

  SymptomAnalysis({
    required this.id,
    required this.userId,
    required this.symptoms,
    required this.severity,
    this.possibleCauses,
    this.immediateAdvice,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symptoms': symptoms,
      'severity': severity,
      'possibleCauses': possibleCauses,
      'immediateAdvice': immediateAdvice,
      'date': date.toIso8601String(),
    };
  }

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      severity: json['severity'] as String,
      possibleCauses: json['possibleCauses'] as String?,
      immediateAdvice: json['immediateAdvice'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

