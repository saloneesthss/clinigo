import 'package:flutter/material.dart';
import 'package:clinigo/db_helper.dart';
import 'package:clinigo/auth_service.dart';
import 'package:clinigo/models.dart';
import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/doctor_card.dart';
import 'package:clinigo/search_screen.dart';
import 'package:clinigo/doctor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _db = DBHelper();
  final AuthService _auth = AuthService();
  String? _userName;
  String? _selectedSpeciality;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _auth.getCurrentUserName();
    if (mounted) setState(() => _userName = name?.split(' ').first);
  }

  Future<List<DoctorModel>> _loadDoctors() async {
    final raw = _selectedSpeciality == null
        ? await _db.getAllDoctors()
        : await _db.getDoctorsBySpeciality(_selectedSpeciality!);
    return raw.map((m) => DoctorModel.fromMap(m)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _refreshKey++),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildSpecialityRow()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  _selectedSpeciality ?? 'All Doctors',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ),
            ),
            SliverToBoxAdapter(
              key: ValueKey(_refreshKey),
              child: FutureBuilder<List<DoctorModel>>(
                future: _loadDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: AppColors.primary)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final doctors = snapshot.data ?? [];
                  if (doctors.isEmpty) {
                    return const Center(
                        child: Padding(padding: EdgeInsets.all(40),
                            child: Text('No doctors found',
                                style: TextStyle(color: AppColors.textSecondary))));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) => DoctorCard(
                      doctor: doctors[index],
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              DoctorDetailScreen(doctorId: doctors[index].id!)))
                          .then((_) => setState(() => _refreshKey++)),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${_userName ?? 'there'} 👋',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('How are you feeling today?',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text((_userName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Book appointments with top doctors in Nepal',
                    style: TextStyle(color: Colors.white, fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textHint, size: 20),
              SizedBox(width: 12),
              Text('Search doctors, specialities...',
                  style: TextStyle(color: AppColors.textHint, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialityRow() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        itemCount: specialities.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _chip(label: 'All', icon: Icons.apps_rounded,
                color: AppColors.primary, isSelected: _selectedSpeciality == null,
                onTap: () => setState(() => _selectedSpeciality = null));
          }
          final spec = specialities[index - 1];
          final isSelected = _selectedSpeciality == spec.name;
          return _chip(label: spec.name, icon: spec.icon, color: spec.color,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedSpeciality = isSelected ? null : spec.name));
        },
      ),
    );
  }

  Widget _chip({required String label, required IconData icon,
    required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
              ),
              child: Icon(icon, color: isSelected ? Colors.white : color, size: 26),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 68,
              child: Text(label,
                  style: TextStyle(fontSize: 10,
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                  textAlign: TextAlign.center, maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}