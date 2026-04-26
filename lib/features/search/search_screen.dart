import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../chat/message_list_screen.dart';
import '../profile/favorites_screen.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../../core/utils/page_transition.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('rooms')
          .where('status', isEqualTo: 'Đã duyệt')
          .get();
      final rooms = snap.docs.map((doc) => Room.fromFirestore(doc)).toList();
      if (mounted) {
        setState(() {
          _allRooms = rooms;
          _filteredRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRooms = _allRooms.where((room) {
        return query.isEmpty ||
            room.title.toLowerCase().contains(query) ||
            room.address.toLowerCase().contains(query);
      }).toList();
    });
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
              _buildSearchBar(context),
              _buildFilterChips(),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_filteredRooms.isEmpty)
                Expanded(child: Center(child: Text('Không tìm thấy phòng.')))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      return _buildRoomCard(_filteredRooms[index], index);
                    },
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
                label: const Text('Map View'),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm phòng trọ...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildChip(Icons.wifi, 'Wifi'),
          const SizedBox(width: 8),
          _buildChip(Icons.payments, '< 5 Triệu'),
          const SizedBox(width: 8),
          _buildChip(Icons.apartment, 'Căn hộ mini'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFCDEFF0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 12, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/600',
                    height: 200, width: double.infinity, fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: index == 0 ? Colors.brown.shade700 : AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(index == 0 ? 'CAO CẤP' : (index == 2 ? 'ĐÁNH GIÁ CAO' : 'NỔI BẬT'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Positioned(
                  top: 16, right: 16,
                  child: CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.favorite, color: Colors.white)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(room.price / 1000000).toStringAsFixed(1)}Tr',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(room.address, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Text('/ THÁNG', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.square_foot, size: 12, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text('${room.area.toStringAsFixed(0)}m²', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.bed, size: 12, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            const Text('Studio', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Explore', true),
            _buildNavItem(Icons.favorite_border, 'Saved', false,
                onTap: () => Navigator.push(context, FadeSlideTransition(page: const FavoritesScreen()))),
            _buildNavItem(Icons.chat_bubble_outline, 'Messages', false,
                onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
            _buildNavItem(Icons.dashboard_customize, 'Manage', false,
                onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const LandlordDashboardScreen()))),
            _buildNavItem(Icons.person_outline, 'Profile', false,
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
