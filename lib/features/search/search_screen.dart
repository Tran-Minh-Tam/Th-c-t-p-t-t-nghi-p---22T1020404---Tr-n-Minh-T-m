import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../../core/utils/page_transition.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Room> _allRooms = Room.getHueMockRooms();
  List<Room> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _filteredRooms = _allRooms;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredRooms = _allRooms
          .where((room) => room.title.toLowerCase().contains(query.toLowerCase()) || 
                           room.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: _filteredRooms.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _filteredRooms.length,
                  itemBuilder: (context, index) => _buildRoomCard(_filteredRooms[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Tìm kiếm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer), textAlign: TextAlign.center),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Nhập địa điểm hoặc tên phòng...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return GestureDetector(
      onTap: () => Navigator.push(context, FadeSlideTransition(page: RoomDetailScreen(room: room))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400x200',
                    height: 200, width: double.infinity, fit: BoxFit.cover,
                  ),
                ),
                if (room.isFeatured)
                  Positioned(
                    top: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
                      child: const Text('NỔI BẬT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.category, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Color(0xFFE2E8F0)),
          SizedBox(height: 16),
          Text('Không tìm thấy phòng phù hợp', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
