import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/safe_network_image.dart';
import 'package:intl/intl.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Hệ thống Duyệt tin', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryContainer),
            onPressed: () {},
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('status', isEqualTo: 'Chờ duyệt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = snapshot.data?.docs ?? [];
          if (rooms.isNotEmpty) {
            rooms.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = (aData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              final bTime = (bData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              return bTime.compareTo(aTime);
            });
          }
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Không có tin nào đang chờ duyệt',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final doc = rooms[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildApprovalCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, String docId, Map<String, dynamic> data) {
    List<dynamic>? imagesList = data['images'] is List ? data['images'] as List : null;
    String firstImage = (imagesList != null && imagesList.isNotEmpty) ? imagesList[0].toString() : 'https://placehold.co/600';
    
    final price = double.tryParse(data['price']?.toString() ?? '0') ?? 0;
    final formatter = NumberFormat('#,###', 'vi_VN');

    String timeAgo = 'Vừa xong';
    if (data['createdAt'] is Timestamp) {
      final date = (data['createdAt'] as Timestamp).toDate();
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) timeAgo = '${diff.inDays} ngày trước';
      else if (diff.inHours > 0) timeAgo = '${diff.inHours} giờ trước';
      else if (diff.inMinutes > 0) timeAgo = '${diff.inMinutes} phút trước';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SafeNetworkImage(imageUrl: firstImage, width: double.infinity, height: 160, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                  child: Text(data['category']?.toString() ?? 'Phòng trọ', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(data['title'] ?? 'Không tiêu đề', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${formatter.format(price)} đ', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data['address'] ?? 'Không địa chỉ', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${data['landlordId'] ?? 'user'}&backgroundColor=b6e3f4'),
                    ),
                    const SizedBox(width: 8),
                    const Text('Người dùng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Đăng $timeAgo', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(context, docId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveRoom(context, docId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Phê duyệt', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String docId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lý do từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng cho biết lý do từ chối tin đăng này:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Thông tin không hợp lệ, hình ảnh không rõ ràng...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateStatus(docId, 'Từ chối', rejectReason: reasonController.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối tin đăng'), backgroundColor: Colors.orange));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRoom(BuildContext context, String docId) async {
    await _updateStatus(docId, 'Đã duyệt');

    final roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(docId).get();
    final landlordId = roomDoc.data()?['landlordId'] as String?;
    final roomTitle = roomDoc.data()?['title'] as String? ?? 'phòng';
    if (landlordId != null && landlordId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': landlordId,
        'title': 'Tin đăng được duyệt',
        'body': 'Tin đăng "$roomTitle" của bạn đã được Admin phê duyệt và công khai.',
        'type': 'room',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phê duyệt tin đăng!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _updateStatus(String docId, String status, {String? rejectReason}) async {
    final Map<String, dynamic> updateData = {'status': status};
    if (rejectReason != null && rejectReason.isNotEmpty) {
      updateData['rejectReason'] = rejectReason;
    }
    await FirebaseFirestore.instance.collection('rooms').doc(docId).update(updateData);

    if (status == 'Từ chối') {
      final roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(docId).get();
      final landlordId = roomDoc.data()?['landlordId'] as String?;
      final roomTitle = roomDoc.data()?['title'] as String? ?? 'phòng';
      if (landlordId != null && landlordId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': landlordId,
          'title': 'Tin đăng bị từ chối',
          'body': rejectReason != null && rejectReason.isNotEmpty
              ? 'Tin "$roomTitle" bị từ chối. Lý do: $rejectReason'
              : 'Tin đăng "$roomTitle" của bạn đã bị từ chối.',
          'type': 'room',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
