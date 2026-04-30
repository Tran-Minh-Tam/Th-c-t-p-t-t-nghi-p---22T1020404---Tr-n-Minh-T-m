import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/page_transition.dart';
import 'package:intl/intl.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../home/main_navigation.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .where('participantIds', arrayContains: currentUser?.uid)
                    
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  final conversations = snapshot.data?.docs ?? [];
                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade200),
                          const SizedBox(height: 16),
                          const Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
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
                        isUnread: false,
                        image: 'https://placehold.co/100',
                        peerId: peerId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tin nhắn', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Quản lý các cuộc trò chuyện của bạn.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            ],
          ),
          GestureDetector(
            onTap: () {
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 4)),
                 (route) => false
               );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4'),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMessageCard(BuildContext context, {required String name, required String message, required String time, required bool isUnread, required String image, String? peerId}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(peerId: peerId ?? 'mock', peerName: name)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$name&backgroundColor=b6e3f4'),
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
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
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      Text(time, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isUnread ? AppTheme.primaryColor : Colors.grey, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnread ? Colors.black : Colors.grey,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                          ),
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
        borderRadius: BorderRadius.circular(20),
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
                    Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54)),
                    Text(time, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
}

