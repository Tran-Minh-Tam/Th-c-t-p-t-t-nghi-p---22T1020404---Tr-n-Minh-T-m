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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Phòng đã lưu', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Color(0xFFE2E8F0)),
                  SizedBox(height: 16),
                  Text('Bạn chưa lưu phòng nào', style: TextStyle(color: Color(0xFF6E797A))),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400x200', height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(room.address, style: const TextStyle(color: Color(0xFF6E797A), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _toggleFavorite(room.id),
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
