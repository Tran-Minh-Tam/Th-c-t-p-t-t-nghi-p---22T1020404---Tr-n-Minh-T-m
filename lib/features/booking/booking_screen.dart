import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  const BookingScreen({super.key, required this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final _noteController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final bookingDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await FirebaseFirestore.instance.collection('bookings').add({
        'roomId': widget.room.id,
        'roomTitle': widget.room.title,
        'landlordId': widget.room.landlordId,
        'userId': user.uid,
        'userName': user.displayName ?? 'Người dùng',
        'bookingTime': Timestamp.fromDate(bookingDateTime),
        'note': _noteController.text.trim(),
        'status': 'Chờ xác nhận',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send notification to landlord
      if (widget.room.landlordId.isNotEmpty) {
        String userName = user.displayName ?? 'Một khách hàng';
        try {
           final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
           userName = userDoc.data()?['fullName'] ?? userName;
        } catch (_) {}
        
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': widget.room.landlordId,
          'title': 'Lịch hẹn xem phòng mới',
          'body': '$userName vừa đặt lịch xem phòng "${widget.room.title}" vào lúc ${DateFormat('HH:mm - dd/MM/yyyy').format(bookingDateTime)}.',
          'type': 'booking',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thành công! Vui lòng chờ chủ trọ xác nhận.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã có lỗi xảy ra'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Đặt lịch xem phòng', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoomCard(),
                const SizedBox(height: 32),
                const Text('Chọn thời gian mong muốn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
                const SizedBox(height: 16),
                _buildDateTimePickers(),
                const SizedBox(height: 32),
                const Text('Ghi chú cho chủ trọ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Tôi muốn xem phòng vào buổi sáng...',
                    hintStyle: TextStyle(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(widget.room.images[0], width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(widget.room.address, style: const TextStyle(color: Color(0xFF6E797A), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
