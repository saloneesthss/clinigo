import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doctor_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        age INTEGER,
        gender TEXT,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        speciality TEXT NOT NULL,
        hospital TEXT NOT NULL,
        experience INTEGER NOT NULL,
        rating REAL NOT NULL,
        fee INTEGER NOT NULL,
        about TEXT,
        available_days TEXT NOT NULL,
        image_color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time_slot TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'upcoming',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (doctor_id) REFERENCES doctors(id)
      )
    ''');

    await _seedDoctors(db);
  }

  Future<void> _seedDoctors(Database db) async {
    final doctors = [
      {
        'name': 'Dr. Sanjay Sharma',
        'speciality': 'Cardiologist',
        'hospital': 'Norvic International Hospital',
        'experience': 12,
        'rating': 4.8,
        'fee': 1500,
        'about': 'Dr. Sharma is a senior cardiologist with 12 years of experience in treating heart conditions. He completed his MD from BPKIHS and has helped over 3000 patients.',
        'available_days': 'Sun,Mon,Tue,Wed,Thu',
        'image_color': 0xFF1565C0,
      },
      {
        'name': 'Dr. Priya Thapa',
        'speciality': 'Dermatologist',
        'hospital': 'Skin Care Clinic, Kathmandu',
        'experience': 8,
        'rating': 4.7,
        'fee': 1200,
        'about': 'Dr. Thapa specializes in skin, hair, and nail disorders. She trained at PGIMER Chandigarh and is known for her patient-friendly approach.',
        'available_days': 'Sun,Mon,Wed,Fri',
        'image_color': 0xFF6A1B9A,
      },
      {
        'name': 'Dr. Rajesh Adhikari',
        'speciality': 'Orthopedist',
        'hospital': 'Grande International Hospital',
        'experience': 15,
        'rating': 4.9,
        'fee': 1800,
        'about': 'Dr. Adhikari is a highly experienced bone and joint specialist. He performs over 200 surgeries per year and is a leading orthopedic consultant in Nepal.',
        'available_days': 'Mon,Tue,Thu,Fri',
        'image_color': 0xFF2E7D32,
      },
      {
        'name': 'Dr. Sunita Karki',
        'speciality': 'Pediatrician',
        'hospital': 'Kanti Children\'s Hospital',
        'experience': 10,
        'rating': 4.6,
        'fee': 1000,
        'about': 'Dr. Karki is a compassionate pediatrician with a decade of experience caring for children from newborns to teenagers.',
        'available_days': 'Sun,Mon,Tue,Wed,Thu,Fri',
        'image_color': 0xFFE65100,
      },
      {
        'name': 'Dr. Bibek Paudel',
        'speciality': 'Neurologist',
        'hospital': 'HAMS Hospital',
        'experience': 9,
        'rating': 4.5,
        'fee': 2000,
        'about': 'Dr. Paudel treats conditions affecting the brain, spinal cord, and nervous system. He is a graduate of TU Institute of Medicine.',
        'available_days': 'Tue,Wed,Thu,Fri',
        'image_color': 0xFF00695C,
      },
      {
        'name': 'Dr. Anita Gurung',
        'speciality': 'Gynecologist',
        'hospital': 'Paropakar Maternity Hospital',
        'experience': 14,
        'rating': 4.8,
        'fee': 1600,
        'about': 'Dr. Gurung is a leading women\'s health specialist with expertise in obstetrics and gynecology. She has delivered over 5000 babies.',
        'available_days': 'Sun,Mon,Tue,Wed,Fri',
        'image_color': 0xFFC62828,
      },
      {
        'name': 'Dr. Mohan Shrestha',
        'speciality': 'ENT Specialist',
        'hospital': 'B&B Hospital',
        'experience': 7,
        'rating': 4.4,
        'fee': 900,
        'about': 'Dr. Shrestha specializes in ear, nose, and throat disorders. He is known for his expertise in treating sinusitis and hearing problems.',
        'available_days': 'Mon,Wed,Thu,Fri',
        'image_color': 0xFF4527A0,
      },
      {
        'name': 'Dr. Deepa Rai',
        'speciality': 'Dentist',
        'hospital': 'Dental Care Clinic, Thamel',
        'experience': 6,
        'rating': 4.6,
        'fee': 800,
        'about': 'Dr. Rai provides comprehensive dental care including fillings, extractions, and cosmetic dentistry. She trained at KIST Medical College.',
        'available_days': 'Sun,Tue,Wed,Thu,Sat',
        'image_color': 0xFF558B2F,
      },
    ];

    for (final doc in doctors) {
      await db.insert('doctors', doc);
    }
  }

  // USER OPERATIONS
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // DOCTORS OPERATIONS
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.query('doctors', orderBy: 'rating DESC');
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final db = await database;
    return await db.query(
      'doctors',
      where: 'name LIKE ? OR speciality LIKE ?',
      whereArgs: ['$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpeciality(String speciality) async {
    final db = await database;
    return await db.query(
      'doctors',
      where: 'speciality = ?',
      whereArgs: [speciality],
    );
  }

  Future<Map<String, dynamic>?> getDoctorById(int id) async {
    final db = await database;
    final result = await db.query('doctors', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // APPOINTMENT OPERATIONS
  Future<int> insertAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment);
  }

  Future<List<Map<String, dynamic>>> getAppointmentsByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        appointments.*,
        doctors.name as doctor_name,
        doctors.speciality as doctor_speciality,
        doctors.hospital as doctor_hospital,
        doctors.image_color as doctor_image_color
      FROM appointments
      JOIN doctors ON appointments.doctor_id = doctors.id
      WHERE appointments.user_id = ?
      ORDER BY appointments.date DESC
    ''', [userId]);
  }

  Future<bool> isSlotBooked(int doctorId, String date, String timeSlot) async {
    final db = await database;
    final result = await db.query(
      'appointments',
      where: 'doctor_id = ? AND date = ? AND time_slot = ? AND status != ?',
      whereArgs: [doctorId, date, timeSlot, 'cancelled'],
    );
    return result.isNotEmpty;
  }

  Future<int> cancelAppointment(int appointmentId) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<int> completeAppointment(int appointmentId) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': 'completed'},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<int> getUpcomingCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE user_id = ? AND status = ?',
      [userId, 'upcoming'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}