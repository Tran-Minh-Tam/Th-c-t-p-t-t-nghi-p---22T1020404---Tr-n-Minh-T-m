import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'approval_screen.dart';
import 'user_management_screen.dart';
import 'report_management_screen.dart';
import 'room_stats_screen.dart';
import 'admin_room_management_screen.dart';

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
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
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
            _buildRealTimeStatsGrid(),
            const SizedBox(height: 32),
            const Text('Quản lý tác vụ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _buildAdminMenu(context),
            const SizedBox(height: 32),
            const Text('Dữ liệu mẫu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _generateMockRooms(context),
                icon: const Icon(Icons.add_to_photos),
                label: const Text('Tạo 25 phòng trọ mẫu (Test)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _generateMockRooms(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      // Ensure user is authenticated to pass Firestore security rules
      if (FirebaseAuth.instance.currentUser == null) {
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } catch (e) {
          if (e is FirebaseAuthException && (e.code == 'admin-restricted-operation' || e.code == 'operation-not-allowed')) {
            throw 'Bạn cần bật chế độ đăng nhập Ẩn danh (Anonymous) trong Firebase Authentication -> Sign-in method, hoặc đăng nhập bằng tài khoản Admin để thực hiện chức năng này.';
          }
          rethrow;
        }
      }

      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      
      final mockImages = [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1000',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?q=80&w=1000',
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1000',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=1000',
        'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?q=80&w=1000',
        'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?q=80&w=1000',
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1000',
        'https://images.unsplash.com/photo-1560448204-61dc36dc98c8?q=80&w=1000',
        'https://images.unsplash.com/photo-1505691723518-36a5ac3be353?q=80&w=1000',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?q=80&w=1000',
        'https://images.unsplash.com/photo-1522771731478-44fb8ac36528?q=80&w=1000'
      ];

      final categories = ['Phòng trọ', 'Căn hộ mini', 'Nhà nguyên căn', 'Studio', 'Ở ghép'];
      final addresses = [
        'Phường Phú Nhuận, TP. Huế',
        'Phường Vĩnh Ninh, TP. Huế',
        'Phường Xuân Phú, TP. Huế',
        'Phường Vỹ Dạ, TP. Huế',
        'Phường An Cựu, TP. Huế',
      ];
      final mockComments = [
        'Phòng rất sạch sẽ và thoáng mát. Chủ nhà thân thiện.',
        'Vị trí thuận lợi, gần trung tâm thành phố. Tiện nghi đầy đủ.',
        'An ninh tốt, có camera giám sát 24/24. Rất yên tâm.',
        'Giá cả hợp lý so với mặt bằng chung. Đáng để thuê.',
        'Phòng giống như trong hình. Không gian yên tĩnh, thích hợp làm việc.'
      ];
      final mockNames = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D', 'Hoàng Văn E'];

      for (int i = 1; i <= 25; i++) {
        final docRef = db.collection('rooms').doc();
        batch.set(docRef, {
          'id': docRef.id,
          'landlordId': FirebaseAuth.instance.currentUser?.uid ?? 'admin_mock',
          'title': 'Phòng trọ cao cấp số $i',
          'description': '🏠 Cho thuê phòng trọ cao cấp, thiết kế hiện đại tại trung tâm Huế.\n\n✨ Đặc điểm nổi bật:\n- Phòng mới xây, sạch sẽ, thoáng mát, có cửa sổ đón nắng gió tự nhiên.\n- Nội thất cơ bản: Giường, tủ quần áo, máy lạnh, máy nước nóng.\n- Bếp nấu ăn riêng biệt, có bồn rửa chén tiện lợi.\n- Khu vực an ninh, trang bị camera giám sát 24/7, khóa vân tay an toàn.\n\n📍 Vị trí đắc địa:\n- Nằm tại khu vực dân cư văn minh, yên tĩnh.\n- Gần các trường đại học lớn, siêu thị, chợ, cửa hàng tiện lợi.\n- Giao thông thuận tiện.\n\n💰 Giá cả hợp lý. Thích hợp cho sinh viên và người đi làm.',
          'address': addresses[i % addresses.length],
          'price': (i % 5 + 2) * 1000000.0,
          'area': (i % 3 + 2) * 10.0,
          'images': [
            mockImages[i % mockImages.length],
            mockImages[(i + 1) % mockImages.length],
            mockImages[(i + 2) % mockImages.length]
          ],
          'category': categories[i % categories.length],
          'status': 'Đã duyệt',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'rating': 4.5,
          'reviewCount': 2,
          'isFeatured': i % 5 == 0,
          'location': GeoPoint(16.4637 + (i * 0.001), 107.5909 + (i * 0.001)),
          'amenities': ['Wifi', 'Điều hòa', 'Chỗ để xe'],
        });

        for (int j = 0; j < 2; j++) {
           final reviewRef = db.collection('reviews').doc();
           batch.set(reviewRef, {
             'roomId': docRef.id,
             'userId': 'mock_user_${i}_$j',
             'userName': mockNames[(i + j) % mockNames.length],
             'rating': 4.0 + (j * 0.5),
             'comment': mockComments[(i + j) % mockComments.length],
             'createdAt': FieldValue.serverTimestamp(),
           });
        }
      }

      await batch.commit();
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo thành công 25 phòng mẫu!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tạo dữ liệu: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildRealTimeStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16, mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildLiveStatCard('Người dùng', Icons.people, Colors.blue,
            FirebaseFirestore.instance.collection('users').snapshots(),
            (snap) => snap.docs.length.toString()),
        _buildLiveStatCard('Phòng trọ', Icons.home, Colors.green,
            FirebaseFirestore.instance.collection('rooms').where('status', isEqualTo: 'Đã duyệt').snapshots(),
            (snap) => snap.docs.length.toString()),
        _buildLiveStatCard('Chờ duyệt', Icons.pending_actions, Colors.orange,
            FirebaseFirestore.instance.collection('rooms').where('status', isEqualTo: 'Chờ duyệt').snapshots(),
            (snap) => snap.docs.length.toString()),
        _buildLiveStatCard('Báo cáo', Icons.report_problem, Colors.red,
            FirebaseFirestore.instance.collection('reports').snapshots(),
            (snap) => snap.docs.length.toString()),
      ],
    );
  }

  Widget _buildLiveStatCard(String label, IconData icon, Color color,
      Stream<QuerySnapshot> stream, String Function(QuerySnapshot) valueBuilder) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? valueBuilder(snapshot.data!) : '...';
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
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
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
        _buildMenuItem(context, 'Quản lý Phòng trọ', Icons.list_alt, 'Chỉnh sửa / Xóa tin đăng', Colors.green, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRoomManagementScreen()));
        }),
        _buildMenuItem(context, 'Xử lý Báo cáo', Icons.report, 'Xem các vi phạm từ User', Colors.red, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportManagementScreen()));
        }),
        _buildMenuItem(context, 'Thống kê chi tiết', Icons.bar_chart, 'Biểu đồ tăng trưởng', Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomStatsScreen()));
        }),
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
