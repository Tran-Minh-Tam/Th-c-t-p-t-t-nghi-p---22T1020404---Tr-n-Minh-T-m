import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Người dùng', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildUserCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, String uid, Map<String, dynamic> data) {
    final role = data['role'] ?? 'user';
    final isBlocked = data['isBlocked'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(data['name']?[0] ?? 'U', style: const TextStyle(color: AppTheme.primaryColor)),
        ),
        title: Text(data['name'] ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data['email'] ?? '', style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(uid, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'set_admin', child: Text('Đặt làm Admin')),
            const PopupMenuItem(value: 'set_landlord', child: Text('Đặt làm Chủ trọ')),
            const PopupMenuItem(value: 'set_user', child: Text('Đặt làm Người thuê')),
            PopupMenuItem(
              value: isBlocked ? 'unblock' : 'block',
              child: Text(isBlocked ? 'Mở khóa' : 'Khóa tài khoản', style: TextStyle(color: isBlocked ? Colors.green : Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String uid, String action) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    switch (action) {
      case 'set_admin': await ref.update({'role': 'admin'}); break;
      case 'set_landlord': await ref.update({'role': 'landlord'}); break;
      case 'set_user': await ref.update({'role': 'user'}); break;
      case 'block': await ref.update({'isBlocked': true}); break;
      case 'unblock': await ref.update({'isBlocked': false}); break;
    }
  }
}
