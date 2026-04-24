import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../chat/message_list_screen.dart';
import '../map/map_screen.dart';
import '../../core/utils/page_transition.dart';
import '../../data/services/api_service.dart';
import '../notification/notification_screen.dart';
import '../../core/widgets/skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final rooms = await ApiService().getRooms();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    _fetchRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildSearchBar(context),
                  _buildCategories(),
                  _isLoading ? _buildSkeletonList() : _buildRoomList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(height: 240, width: double.infinity, borderRadius: 24),
              const SizedBox(height: 16),
              const Skeleton(height: 24, width: 250),
              const SizedBox(height: 8),
              const Skeleton(height: 18, width: 180),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Sanctuary',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                'Tìm kiếm nơi ở lý tưởng',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                },
              ),
              const SizedBox(width: 8),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?u=admin'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, FadeSlideTransition(page: const SearchScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Bạn muốn tìm phòng ở đâu?', style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Tất cả', 'Phòng đơn', 'Căn hộ', 'Nhà nguyên căn', 'Phòng ghép'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomList() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: _rooms.map((room) => _buildRoomItem(room)).toList(),
      ),
    );
  }

  Widget _buildRoomItem(Room room) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoomDetailScreen(room: room)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'room_image_${room.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/600x400',
                  height: 240, width: double.infinity, fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.category.toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${room.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(room.price / 1000000).toStringAsFixed(1)} Tr/tháng • ${room.area}m²',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF191C1C).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Khám phá', true),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false),
            _buildNavItem(Icons.chat_bubble_outline, 'Hộp thư', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
