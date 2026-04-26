import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminRoomManagementScreen extends StatelessWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Phòng trọ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rooms = snapshot.data!.docs;
          if (rooms.isEmpty) return const Center(child: Text('Chưa có phòng nào'));
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final doc = rooms[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'N/A';
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        (data['images'] as List?)?.isNotEmpty == true ? data['images'][0] : 'https://placehold.co/80',
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.home)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(status))),
                          ),
                          const SizedBox(height: 6),
                          Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(currencyFormat.format(data['price'] ?? 0), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleAction(context, doc.id, value, data),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'approve', child: Text('Duyệt')),
                        const PopupMenuItem(value: 'reject', child: Text('Từ chối')),
                        const PopupMenuItem(value: 'hide', child: Text('Ẩn tin')),
                        const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã duyệt': return Colors.green;
      case 'Chờ duyệt': return Colors.orange;
      case 'Từ chối': return Colors.red;
      case 'Tạm ẩn': return Colors.grey;
      default: return Colors.grey;
    }
  }

  void _handleAction(BuildContext context, String docId, String action, Map<String, dynamic> data) async {
    final ref = FirebaseFirestore.instance.collection('rooms').doc(docId);
    switch (action) {
      case 'approve': await ref.update({'status': 'Đã duyệt'}); break;
      case 'reject': await ref.update({'status': 'Từ chối'}); break;
      case 'hide': await ref.update({'status': 'Tạm ẩn'}); break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận xóa?'),
            content: const Text('Thao tác này không thể hoàn tác.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm == true) await ref.delete();
        break;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật!'), backgroundColor: Colors.green));
    }
  }
}
