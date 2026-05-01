import 'package:flutter/material.dart';

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final int? age;
  final String? gender;
  final String? address;
  final String createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.age,
    this.gender,
    this.address,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      age: map['age'],
      gender: map['gender'],
      address: map['address'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'age': age,
      'gender': gender,
      'address': address,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    int? id, String? name, String? email, String? password,
    String? phone, int? age, String? gender, String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: this.createdAt,
    );
  }
}

class DoctorModel {
  final int? id;
  final String name;
  final String speciality;
  final String hospital;
  final int experience;
  final double rating;
  final int fee;
  final String? about;
  final String availableDays;
  final int imageColor;

  DoctorModel({
    this.id,
    required this.name,
    required this.speciality,
    required this.hospital,
    required this.experience,
    required this.rating,
    required this.fee,
    this.about,
    required this.availableDays,
    required this.imageColor,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'],
      name: map['name'],
      speciality: map['speciality'],
      hospital: map['hospital'],
      experience: map['experience'],
      rating: (map['rating'] as num).toDouble(),
      fee: map['fee'],
      about: map['about'],
      availableDays: map['available_days'],
      imageColor: map['image_color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'speciality': speciality,
      'hospital': hospital,
      'experience': experience,
      'rating': rating,
      'fee': fee,
      'about': about,
      'available_days': availableDays,
      'image_color': imageColor,
    };
  }
  List<String> get availableDaysList => availableDays.split(',');
  Color get color => Color(imageColor);
}

class AppointmentModel {
  final int? id;
  final int userId;
  final int doctorId;
  final String date;
  final String timeSlot;
  final String status;
  final String? notes;
  final String createdAt;

  final String? doctorName;
  final String? doctorSpeciality;
  final String? doctorHospital;
  final int? doctorImageColor;

  AppointmentModel({
    this.id,
    required this.userId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
    this.doctorName,
    this.doctorSpeciality,
    this.doctorHospital,
    this.doctorImageColor,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      userId: map['user_id'],
      doctorId: map['doctor_id'],
      date: map['date'],
      timeSlot: map['time_slot'],
      status: map['status'],
      notes: map['notes'],
      createdAt: map['created_at'],
      doctorName: map['doctor_name'],
      doctorSpeciality: map['doctor_speciality'],
      doctorHospital: map['doctor_hospital'],
      doctorImageColor: map['doctor_image_color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'date': date,
      'time_slot': timeSlot,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
  Color get doctorColor => Color(doctorImageColor ?? 0xFF1565C0);
  bool get isToday => date == DateTime.now().toString().substring(0, 10);
}