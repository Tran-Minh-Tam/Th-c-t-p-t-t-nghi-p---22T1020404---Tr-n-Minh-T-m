import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../../core/utils/page_transition.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('PHÒNG ĐÃ LƯU', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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
          final List<String> favoriteIds = List<String>.from(userData?['favorites'] ?? []);

          if (favoriteIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa lưu phòng nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Khám phá ngay', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').where(FieldPath.documentId, whereIn: favoriteIds).snapshots(),
            builder: (context, roomSnapshot) {
              if (roomSnapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
              if (roomSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              final rooms = roomSnapshot.data?.docs.map((doc) => Room.fromFirestore(doc)).toList() ?? [];

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
                  child: Image.network(
                    room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400x250', 
                    height: 220, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(room.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${room.price} Tr/THÁNG',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(child: Text(room.address, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  Future<void> _toggleFavorite(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final List<String> favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

    if (favorites.contains(roomId)) {
      favorites.remove(roomId);
    } else {
      favorites.add(roomId);
    }

    await userRef.update({'favorites': favorites});
  }
}
