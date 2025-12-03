class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String email;
  final String phone;
  final String address;
  final String? bio;
  final double? rating;
  final int? experienceYears;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.phone,
    required this.address,
    this.bio,
    this.rating,
    this.experienceYears,
  });

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? email,
    String? phone,
    String? address,
    String? bio,
    double? rating,
    int? experienceYears,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'address': address,
      'bio': bio,
      'rating': rating,
      'experienceYears': experienceYears,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      bio: json['bio'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      experienceYears: json['experienceYears'] as int?,
    );
  }
}

