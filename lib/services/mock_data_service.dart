import '../models/user.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';

class MockDataService {
  // Utilisateurs pré-définis
  static final List<User> _users = [
    User(
      id: 'admin1',
      email: 'admin@medigeni.com',
      password: 'admin123',
      name: 'Administrateur',
      role: UserRole.admin,
      phone: '+33 1 23 45 67 89',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    User(
      id: 'doctor1',
      email: 'dr.martin@medigeni.com',
      password: 'doctor123',
      name: 'Dr. Martin Dubois',
      role: UserRole.doctor,
      phone: '+33 1 23 45 67 90',
      address: '123 Rue de la Santé, 75014 Paris',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    User(
      id: 'doctor2',
      email: 'dr.bernard@medigeni.com',
      password: 'doctor123',
      name: 'Dr. Bernard Lefebvre',
      role: UserRole.doctor,
      phone: '+33 1 23 45 67 91',
      address: '456 Avenue des Médecins, 69001 Lyon',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    User(
      id: 'doctor3',
      email: 'medecin@medigeni.com',
      password: 'medecin123',
      name: 'Dr. Médecin',
      role: UserRole.doctor,
      phone: '+33 1 23 45 67 92',
      address: '789 Rue du Médecin, 75015 Paris',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    User(
      id: 'patient1',
      email: 'patient@medigeni.com',
      password: 'patient123',
      name: 'Marie Dupont',
      role: UserRole.patient,
      phone: '+33 6 12 34 56 78',
      address: '789 Rue du Patient, 13001 Marseille',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    User(
      id: 'patient2',
      email: 'jean.martin@medigeni.com',
      password: 'patient123',
      name: 'Jean Martin',
      role: UserRole.patient,
      phone: '+33 6 12 34 56 79',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
  ];

  // Médecins pré-définis
  static final List<Doctor> _doctors = [
    Doctor(
      id: 'doctor1',
      name: 'Dr. Martin Dubois',
      specialty: 'Médecine générale',
      email: 'dr.martin@medigeni.com',
      phone: '+33 1 23 45 67 90',
      address: '123 Rue de la Santé, 75014 Paris',
      bio: 'Médecin généraliste avec plus de 15 ans d\'expérience. Spécialisé dans le suivi de patients chroniques.',
      rating: 4.8,
      experienceYears: 15,
    ),
    Doctor(
      id: 'doctor2',
      name: 'Dr. Bernard Lefebvre',
      specialty: 'Cardiologie',
      email: 'dr.bernard@medigeni.com',
      phone: '+33 1 23 45 67 91',
      address: '456 Avenue des Médecins, 69001 Lyon',
      bio: 'Cardiologue expérimenté, spécialisé dans les troubles du rythme cardiaque.',
      rating: 4.9,
      experienceYears: 20,
    ),
    Doctor(
      id: 'doctor3',
      name: 'Dr. Sophie Laurent',
      specialty: 'Gynécologie',
      email: 'dr.laurent@medigeni.com',
      phone: '+33 1 23 45 67 92',
      address: '789 Boulevard de la Santé, 33000 Bordeaux',
      bio: 'Gynécologue-obstétricienne, spécialisée dans le suivi gynécologique et la contraception.',
      rating: 4.7,
      experienceYears: 12,
    ),
    Doctor(
      id: 'doctor4',
      name: 'Dr. Pierre Moreau',
      specialty: 'Dermatologie',
      email: 'dr.moreau@medigeni.com',
      phone: '+33 1 23 45 67 93',
      address: '321 Rue de la Peau, 31000 Toulouse',
      bio: 'Dermatologue spécialisé dans les maladies de la peau et les traitements esthétiques.',
      rating: 4.6,
      experienceYears: 10,
    ),
    Doctor(
      id: 'doctor5',
      name: 'Dr. Claire Rousseau',
      specialty: 'Pédiatrie',
      email: 'dr.rousseau@medigeni.com',
      phone: '+33 1 23 45 67 94',
      address: '654 Avenue des Enfants, 59000 Lille',
      bio: 'Pédiatre expérimentée, spécialisée dans le suivi des enfants et adolescents.',
      rating: 4.9,
      experienceYears: 18,
    ),
    Doctor(
      id: 'doctor6',
      name: 'Dr. Médecin',
      specialty: 'Médecine générale',
      email: 'medecin@medigeni.com',
      phone: '+33 1 23 45 67 92',
      address: '789 Rue du Médecin, 75015 Paris',
      bio: 'Médecin généraliste avec une vaste expérience.',
      rating: 4.8,
      experienceYears: 15,
    ),
  ];

  // Rendez-vous pré-définis
  static final List<Appointment> _appointments = [
    Appointment(
      id: 'apt1',
      patientId: 'patient1',
      patientName: 'Marie Dupont',
      patientEmail: 'patient@medigeni.com',
      patientPhone: '+33 6 12 34 56 78',
      doctorId: 'doctor1',
      doctorName: 'Dr. Martin Dubois',
      doctorSpecialty: 'Médecine générale',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      reason: 'Consultation de routine',
      status: AppointmentStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Appointment(
      id: 'apt2',
      patientId: 'patient2',
      patientName: 'Jean Martin',
      patientEmail: 'jean.martin@medigeni.com',
      patientPhone: '+33 6 12 34 56 79',
      doctorId: 'doctor2',
      doctorName: 'Dr. Bernard Lefebvre',
      doctorSpecialty: 'Cardiologie',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      reason: 'Douleurs thoraciques',
      status: AppointmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Méthodes pour les utilisateurs
  static List<User> getAllUsers() {
    return List.from(_users);
  }

  static User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  static User? login(String email, String password) {
    try {
      // Normaliser l'email et le mot de passe (supprimer les espaces)
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();
      
      // Vérifier si l'email existe
      final userByEmail = _users.firstWhere(
        (user) => user.email.toLowerCase() == normalizedEmail,
        orElse: () => throw Exception('Email not found'),
      );
      
      // Vérifier le mot de passe
      if (userByEmail.password != normalizedPassword) {
        return null;
      }
      
      return userByEmail;
    } catch (e) {
      return null;
    }
  }

  static User? register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? address,
  }) {
    // Vérifier si l'email existe déjà
    if (getUserByEmail(email) != null) {
      return null;
    }

    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      address: address,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    return newUser;
  }

  // Méthodes pour les médecins
  static List<Doctor> getAllDoctors() {
    return List.from(_doctors);
  }

  static Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  // Méthodes pour les rendez-vous
  static List<Appointment> getAllAppointments() {
    return List.from(_appointments);
  }

  static Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((apt) => apt.id == id);
    } catch (e) {
      return null;
    }
  }

  static Appointment createAppointment({
    required String patientId,
    required String patientName,
    required String patientEmail,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime dateTime,
    required String reason,
  }) {
    final appointment = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      patientEmail: patientEmail,
      patientPhone: patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      dateTime: dateTime,
      reason: reason,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );

    _appointments.add(appointment);
    return appointment;
  }

  static bool updateAppointment(String id, Appointment updatedAppointment) {
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      return true;
    }
    return false;
  }
}

