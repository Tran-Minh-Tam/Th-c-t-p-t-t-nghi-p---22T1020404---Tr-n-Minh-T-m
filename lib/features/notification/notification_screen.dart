import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (user == null) return;
              final snap = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .where('isRead', isEqualTo: false)
                  .get();
              for (final doc in snap.docs) {
                await doc.reference.update({'isRead': true});
              }
            },
            child: const Text('Đọc tất cả', style: TextStyle(color: AppTheme.primaryColor, fontSize: 14)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final notifications = snapshot.data?.docs ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 80, color: Color(0xFFE2E8F0)),
                  SizedBox(height: 16),
                  Text('Bạn chưa có thông báo nào', style: TextStyle(color: Color(0xFF6E797A))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;

              return GestureDetector(
                onTap: () async {
                  if (!isRead) {
                    await doc.reference.update({'isRead': true});
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getIconColor(data['type']).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(data['type']), color: _getIconColor(data['type']), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data['title'] ?? 'Thông báo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(_formatDate(data['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(data['body'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'booking': return Icons.event_available;
      case 'message': return Icons.chat_bubble_outline;
      case 'room': return Icons.home_work_outlined;
      default: return Icons.notifications_none;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'booking': return Colors.green;
      case 'message': return Colors.blue;
      case 'room': return Colors.orange;
      default: return AppTheme.primaryColor;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return DateFormat('HH:mm dd/MM').format(date);
  }
}
