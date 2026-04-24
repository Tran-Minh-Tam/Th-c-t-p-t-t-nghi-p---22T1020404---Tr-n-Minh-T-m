import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'approval_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tổng quan hệ thống', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            const Text('Quản lý tác vụ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _buildAdminMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Người dùng', '1,284', Icons.people, Colors.blue),
        _buildStatCard('Phòng trọ', '452', Icons.home, Colors.green),
        _buildStatCard('Chờ duyệt', '12', Icons.pending_actions, Colors.orange),
        _buildStatCard('Báo cáo', '5', Icons.report_problem, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(context, 'Duyệt tin đăng', Icons.approval, 'Phê duyệt phòng trọ mới', Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminApprovalScreen()));
        }),
        _buildMenuItem(context, 'Quản lý Người dùng', Icons.person_search, 'Phân quyền & Khóa tài khoản', Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementScreen()));
        }),
        _buildMenuItem(context, 'Quản lý Phòng trọ', Icons.list_alt, 'Chỉnh sửa / Xóa tin đăng', Colors.green, () {}),
        _buildMenuItem(context, 'Xử lý Báo cáo', Icons.report, 'Xem các vi phạm từ User', Colors.red, () {}),
        _buildMenuItem(context, 'Thống kê chi tiết', Icons.bar_chart, 'Biểu đồ tăng trưởng', Colors.purple, () {}),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String sub, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
