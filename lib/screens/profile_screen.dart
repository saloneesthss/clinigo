import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/database/auth_service.dart';
import 'package:clinigo/database/db_helper.dart';
import 'package:clinigo/models/models.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  int? _selectedAge;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final userId = await AuthService().getCurrentUserId();
    if (userId == null) return;

    final raw = await DBHelper().getUserById(userId);
    if (raw != null && mounted) {
      setState(() {
        _user = UserModel.fromMap(raw);
        _isLoading = false;
      });
    }
  }

  void _startEditing() {
    _nameController.text = _user?.name ?? '';
    _phoneController.text = _user?.phone ?? '';
    _addressController.text = _user?.address ?? '';
    _selectedGender = _user?.gender;
    _selectedAge = _user?.age;
    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await DBHelper().updateUser(_user!.id!, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'gender': _selectedGender,
      'age': _selectedAge,
    });

    await _loadUser();
    if (mounted) setState(() => _isEditing = false);
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppColors.success),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        actions: [
          if (!_isEditing && _user != null)
            TextButton.icon(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text('Edit',
                  style: TextStyle(color: AppColors.primary)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 28),
            _isEditing ? _buildEditForm() : _buildProfileView(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout,
                    size: 18, color: AppColors.error),
                label: const Text('Logout',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = (_user?.name ?? 'U')[0].toUpperCase();
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _user?.name ?? '',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? '',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _profileRow('Phone', _user?.phone ?? 'Not set',
              Icons.phone_outlined),
          _profileRow('Gender', _user?.gender ?? 'Not set',
              Icons.person_outline),
          _profileRow('Age',
              _user?.age != null ? '${_user!.age} years' : 'Not set',
              Icons.cake_outlined),
          _profileRow('Address', _user?.address ?? 'Not set',
              Icons.location_on_outlined),
          _profileRow('Member Since',
              _user?.createdAt.substring(0, 10) ?? '',
              Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline,
                color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined,
                color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.wc_outlined,
                color: AppColors.textSecondary),
          ),
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<int>(
          value: _selectedAge,
          decoration: const InputDecoration(
            labelText: 'Age',
            prefixIcon: Icon(Icons.cake_outlined,
                color: AppColors.textSecondary),
          ),
          items: List.generate(83, (i) => i + 18) // ages 18–100
              .map((age) =>
              DropdownMenuItem(value: age, child: Text('$age years')))
              .toList(),
          onChanged: (v) => setState(() => _selectedAge = v),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on_outlined,
                color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}