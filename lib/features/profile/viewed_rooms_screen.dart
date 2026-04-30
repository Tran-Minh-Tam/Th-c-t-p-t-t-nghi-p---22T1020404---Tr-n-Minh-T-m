import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../home/main_navigation.dart';
import '../../core/utils/page_transition.dart';
import '../../widgets/safe_network_image.dart';

class ViewedRoomsScreen extends StatelessWidget {
  const ViewedRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('TIN ĐÃ XEM', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
          if (userSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final List<String> viewedIds = List<String>.from(userData?['viewedRooms'] ?? []);

          if (viewedIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa xem tin nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 0)),
                      (route) => false
                    ),
                    child: const Text('Khám phá ngay', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          // Reverse to show most recent first
          final reversedIds = viewedIds.reversed.toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').where(FieldPath.documentId, whereIn: reversedIds.take(10).toList()).snapshots(),
            builder: (context, roomSnapshot) {
              if (roomSnapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
              if (roomSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              final rooms = roomSnapshot.data?.docs.map((doc) => Room.fromFirestore(doc)).toList() ?? [];
              
              // Sort rooms to match the order of reversedIds
              rooms.sort((a, b) => reversedIds.indexOf(a.id).compareTo(reversedIds.indexOf(b.id)));

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildRoomCard(context, rooms[index]),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: SafeNetworkImage(
                    imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400x250', 
                    height: 180, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${(room.price/1000000).toStringAsFixed(1)}Tr/THÁNG',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                      const SizedBox(width: 4),
                      Expanded(child: Text(room.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
}
