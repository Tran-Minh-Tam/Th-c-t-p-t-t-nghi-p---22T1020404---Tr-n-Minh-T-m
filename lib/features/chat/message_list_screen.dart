import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/page_transition.dart';
import 'package:intl/intl.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('conversations')
                        .where('participantIds', arrayContains: currentUser?.uid)
                        .orderBy('lastTimestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      final conversations = snapshot.data?.docs ?? [];
                      // If empty, show some mocks based on the design
                      if (conversations.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          children: [
                            _buildMessageCard(context, name: 'Elena Rodriguez', message: 'Tôi đã gửi hợp đồng thuê...', time: '2 PHÚT TRƯỚC', isUnread: true, image: 'https://placehold.co/100'),
                            _buildMessageCard(context, name: 'Marcus Chen', message: 'Lịch xem phòng penthouse...', time: '1 GIỜ TRƯỚC', isUnread: false, image: 'https://placehold.co/100'),
                            _buildMessageCard(context, name: 'Sarah Jenkins', message: 'Cảm ơn! Chúng tôi đã nhận được...', time: 'HÔM QUA', isUnread: false, image: 'https://placehold.co/100'),
                            const SizedBox(height: 24),
                            const Text('ĐÃ LƯU TRỮ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                            const SizedBox(height: 16),
                            _buildArchivedCard(context, name: 'Julian Velez', message: 'Tiền cọc đã được hoàn trả...', time: '12 THÁNG 8', image: 'https://placehold.co/100'),
                            const SizedBox(height: 100),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final doc = conversations[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final participantIds = List<String>.from(data['participantIds']);
                          final peerId = participantIds.firstWhere((id) => id != currentUser?.uid);
                          final participantNames = data['participantNames'] as Map<String, dynamic>?;
                          final peerName = participantNames?[peerId] ?? 'Người dùng';

                          return _buildMessageCard(
                            context,
                            name: peerName,
                            message: data['lastMessage'] ?? '',
                            time: _formatTimestamp(data['lastTimestamp']),
                            isUnread: false, // Defaulting to false for now
                            image: 'https://placehold.co/100', // Mock image
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tin nhắn', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Quản lý các cuộc trò chuyện của bạn với chủ trọ và người thuê.', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Text('Tìm kiếm tin nhắn...', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, {required String name, required String message, required String time, required bool isUnread, required String image}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(peerId: 'mock', peerName: name)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(image),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUnread ? AppTheme.primaryColor : Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(fontSize: 14, color: isUnread ? Colors.black : Colors.grey, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) const Icon(Icons.circle, size: 8, color: AppTheme.primaryColor),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedCard(BuildContext context, {required String name, required String message, required String time, required String image}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(image),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                    Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd/MM').format(date);
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Khám phá', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const HomeScreen()))),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false),
            _buildNavItem(Icons.chat_bubble, 'Tin nhắn', true),
            _buildNavItem(Icons.dashboard_customize, 'Quản lý', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const LandlordDashboardScreen()))),
            _buildNavItem(Icons.person_outline, 'Hồ sơ', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen()))),
          ],
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8), size: 24),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
