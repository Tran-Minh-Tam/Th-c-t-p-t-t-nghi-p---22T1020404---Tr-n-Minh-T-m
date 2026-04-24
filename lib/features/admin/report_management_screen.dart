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
        title: const Text('Báo cáo vi phạm', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

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
            padding: const EdgeInsets.all(24),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('KHẨN CẤP', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text(_formatDate(report['createdAt']), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(report['reason'] ?? 'Không có lý do', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(report['description'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Text('Phòng ID: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        Text(report['roomId'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _deleteReport(context, reportId),
                          child: const Text('Đã xử lý', style: TextStyle(color: Colors.green)),
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }

  Future<void> _deleteReport(BuildContext context, String reportId) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đánh dấu báo cáo là đã xử lý'), backgroundColor: Colors.green));
  }
}
