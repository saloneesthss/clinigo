import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/database/db_helper.dart';
import 'package:clinigo/models/models.dart';
import 'package:flutter/material.dart';
import 'booking_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late Future<DoctorModel?> _doctorFuture;

  @override
  void initState() {
    super.initState();
    _doctorFuture = _loadDoctor();
  }

  Future<DoctorModel?> _loadDoctor() async {
    final raw = await DBHelper().getDoctorById(widget.doctorId);
    return raw != null ? DoctorModel.fromMap(raw) : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorModel?>(
      future: _doctorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final doctor = snapshot.data;
        if (doctor == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Doctor not found')),
          );
        }
        return _buildContent(doctor);
      },
    );
  }

  Widget _buildContent(DoctorModel doctor) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: doctor.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [doctor.color, doctor.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(doctor.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.speciality,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statCard('${doctor.experience}+', 'Years Exp.',
                          Icons.work_outline),
                      const SizedBox(width: 12),
                      _statCard(doctor.rating.toString(), 'Rating',
                          Icons.star_outline),
                      const SizedBox(width: 12),
                      _statCard('Rs.${doctor.fee}', 'Fee',
                          Icons.payments_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Hospital'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: doctor.color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(doctor.hospital,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(
                    doctor.about ?? 'No description available.',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Available Days'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.availableDaysList.map((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: doctor.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: doctor.color.withOpacity(0.3)),
                        ),
                        child: Text(day,
                            style: TextStyle(
                                color: doctor.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingScreen(doctor: doctor)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: doctor.color,
            minimumSize: const Size(double.infinity, 52),
          ),
          child: const Text('Book Appointment',
              style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }

  String _getInitials(String name) {
    final parts =
    name.split(' ').where((p) => p != 'Dr.' && p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts.isNotEmpty ? parts[0][0] : 'D';
  }
}