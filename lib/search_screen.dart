import 'dart:async';
import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/db_helper.dart';
import 'package:clinigo/doctor_card.dart';
import 'package:clinigo/models.dart';
import 'package:flutter/material.dart';
import 'doctor_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final DBHelper _db = DBHelper();

  List<DoctorModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> raw;
    if (query.trim().isEmpty) {
      raw = await _db.getAllDoctors();
    } else {
      raw = await _db.searchDoctors(query.trim());
    }

    if (!mounted) return;
    setState(() {
      _results = raw.map((m) => DoctorModel.fromMap(m)).toList();
      _isLoading = false;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search doctors, specialities...',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                _search('');
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasSearched)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                '${_results.length} doctor${_results.length != 1 ? 's' : ''} found',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
                : _results.isEmpty && _hasSearched
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                return DoctorCard(
                  doctor: _results[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(
                          doctorId: _results[index].id!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No doctors found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Try a different name or speciality',
              style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }
}