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
import '../map/map_screen.dart';
import '../../core/widgets/skeleton.dart';
import '../../widgets/safe_network_image.dart';
import '../home/main_navigation.dart';

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
    return Stack(
      children: [
        Container(
          color: AppTheme.backgroundColor,
          child: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Browse Spaces', style: Theme.of(context).textTheme.titleMedium),
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
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, FadeSlideTransition(page: const MapScreen())),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.map_rounded),
            label: const Text('Xem bản đồ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
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
              IconButton(
                icon: const Icon(Icons.home_rounded, color: AppTheme.primaryColor),
                onPressed: () {
                  // Already at home, but refresh or scroll to top
                },
              ),
              const SizedBox(width: 8),
              Text(
                'TAM RENTED ROOM',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
               // Chuyển sang tab hồ sơ (index 4)
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 4)),
                 (route) => false
               );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4'),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
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
            child: GestureDetector(
              onTap: () => Navigator.push(context, FadeSlideTransition(page: const SearchScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 12),
                    Text('Bạn muốn tìm phòng ở đâu?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context, FadeSlideTransition(page: const SearchScreen(openFilter: true)));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseSpaces() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSpaceCategory(context, Icons.home_rounded, 'NHÀ RIÊNG', const Color(0xFFE0F2F1)),
        _buildSpaceCategory(context, Icons.apartment_rounded, 'CĂN HỘ', const Color(0xFFF1F5F9)),
        _buildSpaceCategory(context, Icons.people_rounded, 'Ở GHÉP', const Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildSpaceCategory(BuildContext context, IconData icon, String label, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, FadeSlideTransition(page: SearchScreen(initialCategory: label)));
      },
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppTheme.primaryContainer, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.blueGrey, letterSpacing: 0.5)),
        ],
      ),
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
              Text('Phòng Nổi Bật', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  Navigator.push(context, FadeSlideTransition(page: const SearchScreen()));
                },
                child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: rooms.take(10).length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room))),
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SafeNetworkImage(
                          imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/600',
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20, left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                          child: const Text('PREMIUM', style: TextStyle(color: AppTheme.primaryColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                      Positioned(
                        top: 20, right: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('TRỐNG PHÒNG', style: TextStyle(color: AppTheme.primaryColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text(room.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${(room.price/1000000).toStringAsFixed(1)}Tr', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                                  const Text('tháng', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w800)),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Tiếp tục khám phá', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8,
          ),
          itemCount: rooms.length > 6 ? 6 : rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room))),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: SafeNetworkImage(imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400', fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${(room.price/1000000).toStringAsFixed(1)} Tr/tháng', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Mới nhất', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rooms.length > 10 ? 10 : rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[rooms.length - 1 - index];
            return GestureDetector(
              onTap: () => Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SafeNetworkImage(imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/100', width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          const Text('Bếp đầy đủ • 2 giường • Wifi', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.primaryColor),
                                  const SizedBox(width: 4),
                                  Text(room.address.split(',').last.trim(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Text('${(room.price/1000000).toStringAsFixed(1)}Tr', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
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
}
