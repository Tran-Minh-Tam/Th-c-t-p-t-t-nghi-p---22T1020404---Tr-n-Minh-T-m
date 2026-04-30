import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ReportManagementScreen extends StatelessWidget {
  const ReportManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Báo cáo', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  Text('Chưa có báo cáo vi phạm nào', style: TextStyle(color: Color(0xFF6E797A))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;
              final reportStatus = report['handlingStatus'] ?? 'pending';

              return _buildReportCard(context, reportId, report, reportStatus);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String reportId, Map<String, dynamic> report, String reportStatus) {
    final timestamp = report['createdAt'];
    String dateStr = 'N/A';
    if (timestamp is Timestamp) {
      dateStr = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    }

    final reason = report['reason'] ?? 'Lý do khác';
    final roomTitle = report['roomTitle'] ?? 'Căn hộ không xác định';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${report['reporterId'] ?? 'user'}&backgroundColor=b6e3f4'),
                  ),
                  const SizedBox(width: 12),
                  const Text('Người dùng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Row(
                children: [
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(reason, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Text(roomTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          if (reportStatus != 'handled')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReport(context, reportId, report, 'warning'),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    label: const Text('Cảnh báo', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReport(context, reportId, report, 'remove_room'),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                    label: const Text('Xóa bài', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReport(context, reportId, report, 'ban_user'),
                    icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white),
                    label: const Text('Khóa TK', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text('Đã xử lý: ${_getHandlingLabel(report['handlingAction'])}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }

  String _getHandlingLabel(String? action) {
    switch (action) {
      case 'warning':
        return 'Cảnh báo';
      case 'remove_room':
        return 'Gỡ bài đăng';
      case 'ban_user':
        return 'Khóa tài khoản';
      default:
        return 'Đã xử lý';
    }
  }

  Future<void> _handleReport(BuildContext context, String reportId, Map<String, dynamic> report, String action) async {
    final labels = {
      'warning': 'cảnh báo chủ bài',
      'remove_room': 'gỡ bài đăng',
      'ban_user': 'khóa tài khoản',
    };
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xử lý'),
        content: Text('Bạn chắc chắn muốn ${labels[action]} này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final db = FirebaseFirestore.instance;
    final roomId = report['roomId'] as String?;

    if (action == 'remove_room' && roomId != null && roomId.isNotEmpty) {
      await db.collection('rooms').doc(roomId).update({'status': 'Tạm ẩn'});
    } else if (action == 'ban_user' && roomId != null && roomId.isNotEmpty) {
      final roomDoc = await db.collection('rooms').doc(roomId).get();
      final landlordId = roomDoc.data()?['landlordId'] as String?;
      if (landlordId != null && landlordId.isNotEmpty) {
        await db.collection('users').doc(landlordId).update({'isBlocked': true});
      }
    }

    await db.collection('reports').doc(reportId).update({
      'handlingStatus': 'handled',
      'handlingAction': action,
      'handledAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã ${labels[action]} thành công!')));
    }
  }
}
