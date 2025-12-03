import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/medical_data.dart';
import '../models/doctor.dart';
import '../services/mock_data_service.dart';

class MedicalProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  List<BMIData> _bmiHistory = [];
  List<PeriodData> _periodHistory = [];
  List<ChatMessage> _chatHistory = [];
  List<SymptomAnalysis> _symptomAnalyses = [];
  List<Doctor> _doctors = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  List<BMIData> get bmiHistory => _bmiHistory;
  List<PeriodData> get periodHistory => _periodHistory;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<SymptomAnalysis> get symptomAnalyses => _symptomAnalyses;
  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;

  MedicalProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _doctors = MockDataService.getAllDoctors();
    _appointments = MockDataService.getAllAppointments();
    notifyListeners();
  }

  // Rendez-vous
  List<Appointment> getAppointmentsByUserId(String userId) {
    return _appointments.where((apt) => apt.patientId == userId || apt.doctorId == userId).toList();
  }

  List<Appointment> getPendingAppointmentsForDoctor(String doctorId) {
    return _appointments
        .where((apt) => apt.doctorId == doctorId && apt.status == AppointmentStatus.pending)
        .toList();
  }

  Future<bool> createAppointment({
    required String patientId,
    required String patientName,
    required String patientEmail,
    required String patientPhone,
    required String doctorId,
    required DateTime dateTime,
    required String reason,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final doctor = _doctors.firstWhere((d) => d.id == doctorId);
      final appointment = MockDataService.createAppointment(
        patientId: patientId,
        patientName: patientName,
        patientEmail: patientEmail,
        patientPhone: patientPhone,
        doctorId: doctorId,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        dateTime: dateTime,
        reason: reason,
      );

      _appointments.add(appointment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus newStatus, {
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: newStatus,
          notes: notes,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // IMC
  void addBMIData(BMIData bmiData) {
    _bmiHistory.insert(0, bmiData);
    notifyListeners();
  }

  BMIData? getLatestBMI(String userId) {
    try {
      return _bmiHistory.where((bmi) => bmi.userId == userId).first;
    } catch (e) {
      return null;
    }
  }

  // Cycle menstruel
  void addPeriodData(PeriodData periodData) {
    _periodHistory.insert(0, periodData);
    notifyListeners();
  }

  PeriodData? getLatestPeriod(String userId) {
    try {
      return _periodHistory.where((p) => p.userId == userId).first;
    } catch (e) {
      return null;
    }
  }

  // Chat
  void addChatMessage(ChatMessage message) {
    _chatHistory.add(message);
    notifyListeners();
  }

  List<ChatMessage> getChatHistoryByUserId(String userId) {
    return _chatHistory.where((msg) => msg.userId == userId).toList();
  }

  void clearChatHistory(String userId) {
    _chatHistory.removeWhere((msg) => msg.userId == userId);
    notifyListeners();
  }

  // Analyse de symptômes
  void addSymptomAnalysis(SymptomAnalysis analysis) {
    _symptomAnalyses.insert(0, analysis);
    notifyListeners();
  }

  // Recherche de médecins
  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return _doctors;
    final lowerQuery = query.toLowerCase();
    return _doctors
        .where((doctor) =>
            doctor.name.toLowerCase().contains(lowerQuery) ||
            doctor.specialty.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Doctor? getDoctorById(String doctorId) {
    try {
      return _doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  // Statistiques pour admin
  Map<String, dynamic> getAdminStats() {
    return {
      'totalUsers': MockDataService.getAllUsers().length,
      'totalDoctors': _doctors.length,
      'totalAppointments': _appointments.length,
      'pendingAppointments': _appointments
          .where((apt) => apt.status == AppointmentStatus.pending)
          .length,
      'completedAppointments': _appointments
          .where((apt) => apt.status == AppointmentStatus.completed)
          .length,
    };
  }
}

