import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transition.dart';
import '../home/home_screen.dart';
import '../chat/message_list_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/favorites_screen.dart';
import 'create_room_screen.dart';
import 'manage_rooms_screen.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  String _fullName = 'Đang tải...';
  int _activeRooms = 0;
  int _pendingRequests = 0;
  double _revenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final roomsSnapshot = await FirebaseFirestore.instance.collection('rooms').where('landlordId', isEqualTo: user.uid).get();
        
        // Mock data for pending and revenue
        setState(() {
          _fullName = doc.data()?['fullName'] ?? 'Minh Quân';
          _activeRooms = roomsSnapshot.docs.length;
          _pendingRequests = 5; // Placeholder
          _revenue = 240000000; // Placeholder
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _fullName = 'Minh Quân';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopAppBar(),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Xin chào, $_fullName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          _buildStatsCards(),
                          const SizedBox(height: 32),
                          _buildMyRoomsSection(),
                          const SizedBox(height: 32),
                          _buildBookingRequestsSection(),
                        ],
                      ),
                    ),
              ),
            ],
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: AppTheme.primaryContainer),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('The', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text('Sanctuary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Thêm phòng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PHÒNG ĐANG CHO THUÊ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const Icon(Icons.meeting_room, size: 16, color: Colors.blueGrey),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    const Text('Phòng đang hiển thị', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHỜ DUYỆT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Text('5', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown)),
                    const Text('Yêu cầu đặt phòng', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DOANH THU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 12),
              const Text('14.5M VNĐ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Dự kiến tháng này', style: TextStyle(fontSize: 10, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyRoomsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Phòng của tôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsScreen())),
              child: const Text('Xem tất cả', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRoomList(),
      ],
    );
  }

  Widget _buildRoomList() {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').where('landlordId', isEqualTo: user?.uid).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rooms = snapshot.data!.docs;
        if (rooms.isEmpty) return const Text('Bạn chưa có phòng nào.');

        return Column(
          children: rooms.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      (data['images'] as List?)?.isNotEmpty == true ? data['images'][0] : 'https://placehold.co/100',
                      width: 80, height: 80, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Text(data['status'] ?? '', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(data['address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('\$${(data['price'] / 24000).toStringAsFixed(0)}/mo', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {}),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBookingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.brown, size: 20),
            SizedBox(width: 8),
            Text('Booking Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildBookingRequestItem('Linh Tran', 'Requested 2h ago', 'Interested in Deluxe Studio - Landmark 81 starting Nov 1st.'),
              const Divider(),
              _buildBookingRequestItem('Minh Quan', 'Requested 5h ago', 'Interested in Urban Loft - District 1 for viewing.'),
              const Divider(),
              _buildBookingRequestItem('Thu Ha', 'Yesterday', 'Viewed details 14 times.', showButtons: false),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black87),
                  child: const Text('History'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingRequestItem(String name, String time, String desc, {bool showButtons = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(time.toUpperCase(), style: const TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 12)),
          if (showButtons) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Accept', style: TextStyle(fontSize: 12)),
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryContainer,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(8)),
                child: const Text('CHỜ DUYỆT', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(roomTitle, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chấp nhận'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.search, 'Khám phá', false,
              onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const HomeScreen()))),
          _buildNavItem(Icons.favorite_border, 'Đã lưu', false,
              onTap: () => Navigator.push(context, FadeSlideTransition(page: const FavoritesScreen()))),
          _buildNavItem(Icons.chat_bubble_outline, 'Tin nhắn', false,
              onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
          _buildNavItem(Icons.dashboard_customize, 'Quản lý', true),
          _buildNavItem(Icons.person_outline, 'Hồ sơ', false,
              onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen()))),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
