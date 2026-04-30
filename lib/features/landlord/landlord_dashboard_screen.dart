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
import 'edit_room_screen.dart';

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopAppBar(),
                const SizedBox(height: 24),
                Text('Xin chào, $_fullName', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 32),
                _buildMyRoomsSection(),
                const SizedBox(height: 32),
                _buildBookingRequestsSection(),
              ],
            ),
          ),
    );
  }

  Widget _buildTopAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.menu, color: AppTheme.primaryContainer),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VĂN PHÒNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                Text('QUẢN LÝ', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('Thêm phòng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem('PHÒNG HIỆN CÓ', _activeRooms.toString(), Icons.meeting_room, Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem('CHỜ DUYỆT', _pendingRequests.toString(), Icons.pending_actions, Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF004D40)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DOANH THU ƯỚC TÍNH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Text('${(_revenue/1000000).toStringAsFixed(1)}M VNĐ', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Cập nhật 2 phút trước', style: TextStyle(fontSize: 10, color: Colors.white60)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.primaryContainer)),
        ],
      ),
    );
  }

  Widget _buildMyRoomsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phòng của bạn', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsScreen())),
              child: const Text('Xem tất cả', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                        Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(data['address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                              child: Text(data['status'] ?? 'Trống', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                            ),
                            const SizedBox(width: 8),
                            Text('${(data['price']/1000000).toStringAsFixed(1)}Tr/th', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note_outlined, color: Colors.blueGrey, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRoomScreen(
                                roomId: doc.id,
                                roomData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                        onPressed: () {
                          _showDeleteConfirm(doc.id);
                        },
                      ),
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

  void _showDeleteConfirm(String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa phòng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('rooms').doc(roomId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Yêu cầu đặt phòng', style: Theme.of(context).textTheme.titleLarge),
            const Icon(Icons.notifications_none, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildBookingRequestItem('Linh Tran', '2 giờ trước', 'Muốn xem phòng Deluxe Studio vào sáng mai.'),
              const Divider(height: 32),
              _buildBookingRequestItem('Minh Quân', '5 giờ trước', 'Hỏi về phí gửi xe và giờ giấc tự do.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng lịch sử đang được phát triển')));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  child: const Text('Xem lịch sử giao dịch', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.w800)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingRequestItem(String name, String time, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(8)),
              child: const Text('CHỜ DUYỆT', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(desc, style: const TextStyle(fontSize: 13, color: Colors.blueGrey, height: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu')));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Color(0xFFFEE2E2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chấp nhận yêu cầu. Đang liên hệ với khách hàng...')));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Chấp nhận', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
