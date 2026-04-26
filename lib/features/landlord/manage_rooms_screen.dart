import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'edit_room_screen.dart';

class ManageRoomsScreen extends StatelessWidget {
  const ManageRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tin đã đăng', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').where('landlordId', isEqualTo: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final rooms = snapshot.data?.docs ?? [];
          if (rooms.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center_outlined, size: 80, color: AppTheme.primaryContainer.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                const Text('Bạn chưa đăng tin nào', style: TextStyle(color: Color(0xFF6E797A))),
              ],
            ));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final doc = rooms[index];
              final room = doc.data() as Map<String, dynamic>;
              final roomId = doc.id;
              final status = room['status'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                      child: Image.network(
                        (room['images'] as List?)?.isNotEmpty == true ? room['images'][0] : 'https://placehold.co/100',
                        width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.home)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                          ),
                          const SizedBox(height: 8),
                          Text(room['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(currencyFormat.format(room['price'] ?? 0), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF6E797A)),
                      onPressed: () => _showOptions(context, roomId, room),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Đã duyệt': return Colors.green;
      case 'Chờ duyệt': return Colors.orange;
      case 'Từ chối': return Colors.red;
      case 'Tạm ẩn': return Colors.grey;
      default: return Colors.grey;
    }
  }

  void _showOptions(BuildContext context, String roomId, Map<String, dynamic> room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(Icons.edit_outlined, 'Chỉnh sửa tin đăng', Colors.blue, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditRoomScreen(roomId: roomId, roomData: room)));
            }),
            _buildOptionItem(
              room['status'] == 'Tạm ẩn' ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              room['status'] == 'Tạm ẩn' ? 'Hiện tin trở lại' : 'Tạm ẩn tin',
              Colors.orange,
              () {
                Navigator.pop(context);
                final newStatus = room['status'] == 'Tạm ẩn' ? 'Đã duyệt' : 'Tạm ẩn';
                FirebaseFirestore.instance.collection('rooms').doc(roomId).update({'status': newStatus});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(newStatus == 'Tạm ẩn' ? 'Đã ẩn tin đăng' : 'Đã hiện tin đăng'), backgroundColor: Colors.green),
                );
              },
            ),
            _buildOptionItem(Icons.delete_outline, 'Xóa tin đăng', Colors.red, () {
              Navigator.pop(context);
              _confirmDelete(context, roomId);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color), title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), onTap: onTap);
  }

  void _confirmDelete(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Bạn có chắc chắn muốn xóa tin đăng này không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('rooms').doc(roomId).delete();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa tin đăng'), backgroundColor: Colors.green));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
