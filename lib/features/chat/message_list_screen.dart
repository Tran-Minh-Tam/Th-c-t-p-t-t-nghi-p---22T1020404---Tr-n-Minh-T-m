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
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopAppBar(),
              const Divider(height: 1, color: Color(0xFFF0F4F4)),
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
                    if (conversations.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 80, color: Color(0xFFE2E8F0)),
                            SizedBox(height: 16),
                            Text('Chưa có cuộc hội thoại nào', style: TextStyle(color: Color(0xFF6E797A))),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final doc = conversations[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final participantIds = List<String>.from(data['participantIds']);
                        final peerId = participantIds.firstWhere((id) => id != currentUser?.uid);
                        final participantNames = data['participantNames'] as Map<String, dynamic>?;
                        final peerName = participantNames?[peerId] ?? 'Người dùng';

                        return _buildMessageItem(
                          context,
                          peerId: peerId,
                          name: peerName,
                          message: data['lastMessage'] ?? '',
                          time: _formatTimestamp(data['lastTimestamp']),
                          unreadCount: 0, // Logic for unread count can be added later
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          _buildBottomNavigationBar(context),
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

  Widget _buildTopAppBar() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.menu, color: AppTheme.primaryContainer),
              SizedBox(width: 16),
              Text(
                'TIN NHẮN',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          Icon(Icons.search, color: AppTheme.primaryContainer),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, {required String peerId, required String name, required String message, required String time, int unreadCount = 0}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(peerId: peerId, peerName: name)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Center(child: Text(name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
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
                      Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(message, style: TextStyle(color: unreadCount > 0 ? AppTheme.primaryContainer : const Color(0xFF64748B), fontSize: 14, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(10)),
                          child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Khám phá', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const HomeScreen()))),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false),
            _buildNavItem(Icons.chat_bubble, 'Hộp thư', true),
            _buildNavItem(Icons.person_outline, 'Cá nhân', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen()))),
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
            decoration: BoxDecoration(color: isActive ? AppTheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: isActive ? AppTheme.primaryContainer : const Color(0xFF94A3B8), size: 24),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: isActive ? AppTheme.primaryContainer : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
