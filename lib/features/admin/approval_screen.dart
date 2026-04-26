import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Duyệt tin đăng',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('status', isEqualTo: 'Chờ duyệt')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data?.docs ?? [];
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
            padding: const EdgeInsets.all(24),
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

  Widget _buildApprovalCard(
      BuildContext context, String docId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  (data['images'] as List?)?.isNotEmpty == true
                      ? data['images'][0]
                      : 'https://placehold.co/100',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 80, height: 80, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Không tiêu đề',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['address'] ?? 'Không địa chỉ',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      '${((data['price'] ?? 0) / 1000000).toStringAsFixed(1)} Tr/tháng',
                      style: const TextStyle(
                          color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data['category'] ?? 'Phòng trọ',
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((data['description'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              data['description'] ?? '',
              style: const TextStyle(color: Color(0xFF6E797A), fontSize: 13, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(context, docId),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Từ chối'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveRoom(context, docId),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Phê duyệt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
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
        title: const Text('Lý do từ chối'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng cho biết lý do từ chối tin đăng này:',
                style: TextStyle(color: Colors.grey)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateStatus(docId, 'Từ chối',
                  rejectReason: reasonController.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Đã từ chối tin đăng'),
                      backgroundColor: Colors.orange),
                );
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

    // Send notification to landlord
    final roomDoc =
        await FirebaseFirestore.instance.collection('rooms').doc(docId).get();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã phê duyệt tin đăng!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _updateStatus(String docId, String status, {String? rejectReason}) async {
    final Map<String, dynamic> updateData = {'status': status};
    if (rejectReason != null && rejectReason.isNotEmpty) {
      updateData['rejectReason'] = rejectReason;
    }
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .update(updateData);

    // Notify landlord if rejected
    if (status == 'Từ chối') {
      final roomDoc =
          await FirebaseFirestore.instance.collection('rooms').doc(docId).get();
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
