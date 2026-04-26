import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class ReportManagementScreen extends StatelessWidget {
  const ReportManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Báo cáo vi phạm',
            style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data?.docs ?? [];
          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có báo cáo vi phạm nào',
                      style: TextStyle(color: Color(0xFF6E797A))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;
              final reportStatus = report['handlingStatus'] ?? 'pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
                  ],
                  border: reportStatus == 'handled'
                      ? Border.all(color: Colors.green.withValues(alpha: 0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (reportStatus == 'handled')
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('ĐÃ XỬ LÝ',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          )
                        else
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('CHỜ XỬ LÝ',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        Text(
                          _formatDate(report['createdAt']),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report['reason'] ?? 'Không có lý do',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Phòng ID: ${report['roomId'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (reportStatus != 'handled')
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Cảnh báo',
                              icon: Icons.warning_amber_outlined,
                              color: Colors.orange,
                              onTap: () => _handleReport(
                                context, reportId, report, 'warning'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Gỡ tin',
                              icon: Icons.block_outlined,
                              color: Colors.red,
                              onTap: () => _handleReport(
                                context, reportId, report, 'remove_room'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Khóa TK',
                              icon: Icons.person_off_outlined,
                              color: Colors.purple,
                              onTap: () => _handleReport(
                                context, reportId, report, 'ban_user'),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _getHandlingLabel(report['handlingAction']),
                            style: const TextStyle(color: Colors.green, fontSize: 13),
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _getHandlingLabel(String? action) {
    switch (action) {
      case 'warning':
        return 'Đã cảnh báo chủ trọ';
      case 'remove_room':
        return 'Đã gỡ tin đăng';
      case 'ban_user':
        return 'Đã khóa tài khoản';
      default:
        return 'Đã xử lý';
    }
  }

  Future<void> _handleReport(
    BuildContext context,
    String reportId,
    Map<String, dynamic> report,
    String action,
  ) async {
    final labels = {
      'warning': 'cảnh báo chủ trọ',
      'remove_room': 'gỡ tin đăng',
      'ban_user': 'khóa tài khoản',
    };
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xử lý'),
        content: Text('Bạn muốn ${labels[action]} cho báo cáo này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final db = FirebaseFirestore.instance;
    final roomId = report['roomId'] as String?;

    if (action == 'remove_room' && roomId != null && roomId.isNotEmpty) {
      // Gỡ tin đăng: chuyển trạng thái phòng thành "Tạm ẩn"
      await db.collection('rooms').doc(roomId).update({'status': 'Tạm ẩn'});
    } else if (action == 'ban_user' && roomId != null && roomId.isNotEmpty) {
      // Khóa tài khoản landlord của phòng đó
      final roomDoc = await db.collection('rooms').doc(roomId).get();
      final landlordId = roomDoc.data()?['landlordId'] as String?;
      if (landlordId != null && landlordId.isNotEmpty) {
        await db.collection('users').doc(landlordId).update({'isBlocked': true});
      }
    }

    // Đánh dấu report đã xử lý
    await db.collection('reports').doc(reportId).update({
      'handlingStatus': 'handled',
      'handlingAction': action,
      'handledAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã ${labels[action]} thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }
}
