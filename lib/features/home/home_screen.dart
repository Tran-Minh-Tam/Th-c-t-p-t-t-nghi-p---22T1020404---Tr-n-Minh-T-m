import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../chat/message_list_screen.dart';
import '../../core/utils/page_transition.dart';
import '../notification/notification_screen.dart';
import '../profile/favorites_screen.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../../core/widgets/skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<List<Room>> _getRoomsStream() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .where('status', isEqualTo: 'Đã duyệt')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Room.fromFirestore(doc)).toList());
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Browse Spaces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      _buildBrowseSpaces(),
                      const SizedBox(height: 32),
                      
                      StreamBuilder<List<Room>>(
                        stream: _getRoomsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final rooms = snapshot.data ?? [];
                          
                          final featuredRooms = rooms.where((r) => r.isFeatured).toList();
                          final otherRooms = rooms.where((r) => !r.isFeatured).toList();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeaturedSection(featuredRooms.isNotEmpty ? featuredRooms : rooms),
                              const SizedBox(height: 32),
                              _buildContinueExploring(otherRooms.isNotEmpty ? otherRooms : rooms),
                              const SizedBox(height: 32),
                              _buildLatestArrivals(rooms),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 100, left: 0, right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined),
                label: const Text('Show map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                ),
              ),
            ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: AppTheme.primaryContainer),
              const SizedBox(width: 16),
              const Text(
                'The Sanctuary',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen())),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text('Bạn muốn tìm phòng ở đâu?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseSpaces() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSpaceCategory(Icons.home, 'NHÀ NGUYÊN CĂN', const Color(0xFFCDEFF0)),
        _buildSpaceCategory(Icons.apartment, 'CĂN HỘ MINI', const Color(0xFFEEEEEE)),
        _buildSpaceCategory(Icons.people, 'Ở GHÉP', const Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildSpaceCategory(IconData icon, String label, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }

  Widget _buildFeaturedSection(List<Room> rooms) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phòng Nổi Bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: rooms.take(3).length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room))),
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/600'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16, left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.brown.shade700, borderRadius: BorderRadius.circular(8)),
                          child: const Text('CAO CẤP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        top: 16, right: 16,
                        child: const CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.favorite_border, color: Colors.white)),
                      ),
                      Positioned(
                        bottom: 16, left: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TRỐNG PHÒNG', style: TextStyle(color: Colors.brown, fontSize: 8, fontWeight: FontWeight.bold)),
                                  Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('${(room.price/1000000).toStringAsFixed(1)}Tr', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('mỗi tháng', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueExploring(List<Room> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Tiếp tục khám phá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
          ),
          itemCount: rooms.length > 2 ? 2 : rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room))),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400', fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(room.address, style: const TextStyle(color: Colors.grey, fontSize: 8), maxLines: 1),
                          const SizedBox(height: 4),
                          Text('${(room.price/1000000).toStringAsFixed(1)}Tr/tháng', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLatestArrivals(List<Room> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Mới nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rooms.length > 2 ? 2 : rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[rooms.length - 1 - index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/100', width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1)),
                              const Icon(Icons.bookmark, color: Colors.grey, size: 16),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Bếp đầy đủ • 2 giường • Wifi', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 10, color: AppTheme.primaryColor),
                                  Text(room.address, style: const TextStyle(color: Colors.grey, fontSize: 8)),
                                ],
                              ),
                              Text('${(room.price/1000000).toStringAsFixed(1)}Tr/tháng', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
            _buildNavItem(Icons.search, 'Khám phá', true),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false,
                onTap: () => Navigator.push(context, FadeSlideTransition(page: const FavoritesScreen()))),
            _buildNavItem(Icons.chat_bubble_outline, 'Tin nhắn', false,
                onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
            _buildNavItem(Icons.dashboard_customize, 'Quản lý', false,
                onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const LandlordDashboardScreen()))),
            _buildNavItem(Icons.person_outline, 'Hồ sơ', false,
                onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen()))),
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
