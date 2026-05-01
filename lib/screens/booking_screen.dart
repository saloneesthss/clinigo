import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinigo/database/db_helper.dart';
import 'package:clinigo/database/auth_service.dart';
import 'package:clinigo/models/models.dart';
import 'package:clinigo/constants/app_theme.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final DoctorModel doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  bool _isLoading = false;
  final _notesController = TextEditingController();
  Map<String, bool> _bookedSlots = {};

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedSlots(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final booked = <String, bool>{};

    for (final slot in timeSlots) {
      final isBooked =
      await DBHelper().isSlotBooked(widget.doctor.id!, dateStr, slot);
      booked[slot] = isBooked;
    }

    if (mounted) setState(() => _bookedSlots = booked);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: widget.doctor.color),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
        _bookedSlots = {};
      });
      await _loadBookedSlots(picked);
    }
  }

  bool _isDayAvailable(DateTime date) {
    final dayName = DateFormat('EEE').format(date);
    return widget.doctor.availableDaysList.contains(dayName);
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_selectedSlot == null) {
      _showSnack('Please select a time slot');
      return;
    }

    setState(() => _isLoading = true);

    final userId = await AuthService().getCurrentUserId();
    if (userId == null) {
      _showSnack('Please login again');
      setState(() => _isLoading = false);
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final alreadyBooked = await DBHelper().isSlotBooked(widget.doctor.id!, dateStr, _selectedSlot!);

    if (alreadyBooked) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('This slot was just booked. Please choose another.');
        _loadBookedSlots(_selectedDate!);
      }
      return;
    }

    final appointmentId = await DBHelper().insertAppointment({
      'user_id': userId,
      'doctor_id': widget.doctor.id,
      'date': dateStr,
      'time_slot': _selectedSlot,
      'status': 'upcoming',
      'notes': _notesController.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          doctor: widget.doctor,
          date: _selectedDate!,
          timeSlot: _selectedSlot!,
          appointmentId: appointmentId,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorSummary(),
            const SizedBox(height: 24),

            _sectionTitle('Select Date'),
            const SizedBox(height: 10),
            _buildDateButton(),
            const SizedBox(height: 24),

            if (_selectedDate != null) ...[
              _sectionTitle('Select Time Slot'),
              const SizedBox(height: 10),
              _buildTimeSlots(),
              const SizedBox(height: 24),
            ],

            _sectionTitle('Notes (optional)'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms or reason for visit...',
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.doctor.color,
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Confirm Booking',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.doctor.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.doctor.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: widget.doctor.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _getInitials(widget.doctor.name),
                style: TextStyle(
                  color: widget.doctor.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctor.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15)),
                Text(widget.doctor.speciality,
                    style: TextStyle(
                        color: widget.doctor.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('Rs. ${widget.doctor.fee}',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: widget.doctor.color,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null
                ? widget.doctor.color
                : AppColors.divider,
            width: _selectedDate != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: widget.doctor.color, size: 18),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Choose a date'
                  : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null
                    ? AppColors.textHint
                    : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDate != null && !_isDayAvailable(_selectedDate!)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFF39C12), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dr. ${widget.doctor.name.split(' ').last} is not available on ${DateFormat('EEEE').format(_selectedDate!)}s.',
                style: const TextStyle(color: Color(0xFFF39C12), fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: timeSlots.map((slot) {
        final isBooked = _bookedSlots[slot] == true;
        final isSelected = _selectedSlot == slot;

        return GestureDetector(
          onTap: isBooked ? null : () => setState(() => _selectedSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isBooked
                  ? AppColors.inputBg
                  : isSelected
                  ? widget.doctor.color
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBooked
                    ? AppColors.divider
                    : isSelected
                    ? widget.doctor.color
                    : AppColors.divider,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isBooked
                    ? AppColors.textHint
                    : isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      }).toList(),
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
    final parts = name.split(' ').where((p) => p != 'Dr.' && p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts.isNotEmpty ? parts[0][0] : 'D';
  }
}