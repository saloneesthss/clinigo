import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/auth_service.dart';
import 'package:clinigo/db_helper.dart';
import 'package:clinigo/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppointmentModel> _all = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final userId = await AuthService().getCurrentUserId();
    if (userId == null) return;

    final raw = await DBHelper().getAppointmentsByUser(userId);
    if (mounted) {
      setState(() {
        _all = raw.map((m) => AppointmentModel.fromMap(m)).toList();
        _isLoading = false;
      });
    }
  }

  List<AppointmentModel> get _upcoming =>
      _all.where((a) => a.status == 'upcoming').toList();
  List<AppointmentModel> get _completed =>
      _all.where((a) => a.status == 'completed').toList();
  List<AppointmentModel> get _cancelled =>
      _all.where((a) => a.status == 'cancelled').toList();

  Future<void> _cancelAppointment(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper().cancelAppointment(id);
      _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments',
            style: TextStyle(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Completed (${_completed.length})'),
            Tab(text: 'Cancelled (${_cancelled.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(_upcoming, showCancel: true),
          _buildList(_completed),
          _buildList(_cancelled),
        ],
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> appointments,
      {bool showCancel = false}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 60, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text('No appointments here',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(
              appointments[index], showCancel);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt, bool showCancel) {
    Color statusColor;
    IconData statusIcon;
    switch (appt.status) {
      case 'upcoming':
        statusColor = AppColors.primary;
        statusIcon = Icons.upcoming_outlined;
        break;
      case 'completed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = AppColors.cancelled;
        statusIcon = Icons.cancel_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: appt.doctorColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    _getInitials(appt.doctorName ?? 'Doctor'),
                    style: TextStyle(
                      color: appt.doctorColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.doctorName ?? 'Unknown Doctor',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      appt.doctorSpeciality ?? '',
                      style: TextStyle(
                          color: appt.doctorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      appt.status[0].toUpperCase() + appt.status.substring(1),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider, height: 1),
          ),

          Row(
            children: [
              _infoChip(Icons.calendar_today_outlined,
                  _formatDate(appt.date)),
              const SizedBox(width: 10),
              _infoChip(Icons.access_time_rounded, appt.timeSlot),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(
              Icons.local_hospital_outlined, appt.doctorHospital ?? ''),

          if (appt.notes != null && appt.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appt.notes!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],

          if (showCancel && appt.status == 'upcoming') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cancelAppointment(appt.id!),
                icon: const Icon(Icons.cancel_outlined,
                    size: 16, color: AppColors.error),
                label: const Text('Cancel Appointment',
                    style: TextStyle(
                        color: AppColors.error, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEE, MMM d yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _getInitials(String name) {
    final parts =
    name.split(' ').where((p) => p != 'Dr.' && p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts.isNotEmpty ? parts[0][0] : 'D';
  }
}