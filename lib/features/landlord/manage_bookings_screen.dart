import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý lịch hẹn', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('landlordId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data?.docs ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('Chưa có lịch hẹn nào', style: TextStyle(color: Color(0xFF6E797A))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final bookingId = bookings[index].id;
              final time = (booking['bookingTime'] as Timestamp).toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking['userName'] ?? 'Người dùng',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        _buildStatusBadge(booking['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking['roomTitle'] ?? 'Phòng không xác định',
                      style: TextStyle(color: AppTheme.primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6E797A)),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy - HH:mm').format(time), style: const TextStyle(color: Color(0xFF6E797A))),
                      ],
                    ),
                    if (booking['note'] != null && booking['note'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFF6E797A)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(booking['note'], style: const TextStyle(color: Color(0xFF6E797A), fontSize: 14))),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (booking['status'] == 'Chờ xác nhận')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus(bookingId, 'Từ chối'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Từ chối'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(bookingId, 'Đã xác nhận'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Xác nhận'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Đã xác nhận') color = Colors.green;
    if (status == 'Từ chối') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': newStatus});
  }
}
