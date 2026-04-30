import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import '../room_detail/room_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../chat/message_list_screen.dart';
import '../profile/favorites_screen.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../map/map_screen.dart';
import '../../widgets/safe_network_image.dart';
import '../../core/utils/page_transition.dart';
import '../home/main_navigation.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final bool openFilter;
  const SearchScreen({super.key, this.initialCategory, this.openFilter = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = true;
  String _userRole = 'user';
  RangeValues _priceRange = const RangeValues(0, 10000000);
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchRooms().then((_) {
      if (widget.initialCategory != null) {
        _applyInitialFilter(widget.initialCategory!);
      }
      if (widget.openFilter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFilterDialog();
        });
      }
    });
    _fetchUserRole();
  }

  void _applyInitialFilter(String category) {
    setState(() {
      _filteredRooms = _allRooms.where((room) {
        // Map category label to room data types
        if (category == 'NHÀ RIÊNG') {
          return room.category == 'Nhà nguyên căn' || room.category == 'Nhà riêng';
        } else if (category == 'CĂN HỘ') {
          return room.category == 'Căn hộ mini' || room.category == 'Studio' || room.category == 'Căn hộ';
        } else if (category == 'Ở GHÉP') {
          return room.category == 'Ở ghép';
        }
        return room.category == category;
      }).toList();
    });
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
        final matchesQuery = query.isEmpty ||
            room.title.toLowerCase().contains(query) ||
            room.address.toLowerCase().contains(query);
        
        final matchesPrice = room.price >= _priceRange.start && room.price <= _priceRange.end;
        
        bool matchesCategory = true;
        if (_selectedCategory != 'Tất cả') {
          if (_selectedCategory == 'Nhà riêng') {
            matchesCategory = room.category == 'Nhà nguyên căn' || room.category == 'Nhà riêng';
          } else if (_selectedCategory == 'Căn hộ') {
            matchesCategory = room.category == 'Căn hộ mini' || room.category == 'Studio' || room.category == 'Căn hộ';
          } else {
            matchesCategory = room.category == _selectedCategory;
          }
        }
        
        return matchesQuery && matchesPrice && matchesCategory;
      }).toList();
    });
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _userRole = doc.data()?['role'] ?? 'user';
          });
        }
      } catch (e) {
        debugPrint('Error fetching user role: $e');
      }
    }
  }

  void _openMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
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
                onPressed: () => _openMapView(),
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
          // _buildBottomNavigationBar(context),
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
              IconButton(
                icon: const Icon(Icons.home_rounded, color: AppTheme.primaryColor),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: 0)),
                    (route) => false
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'TAM RENTED ROOM',
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
            onTap: () {
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: 4)),
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
          GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
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
                  child: SafeNetworkImage(
                    imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/400',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
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
    List<NavItemData> navItems = [
      NavItemData(Icons.search, 'Explore', true),
      NavItemData(Icons.favorite_border, 'Saved', false, () => Navigator.push(context, FadeSlideTransition(page: const FavoritesScreen()))),
      NavItemData(Icons.chat_bubble_outline, 'Messages', false, () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
    ];

    // Only show management option for landlords
    if (_userRole == 'landlord') {
      navItems.add(NavItemData(Icons.dashboard_customize, 'Manage', false, () => Navigator.pushReplacement(context, FadeSlideTransition(page: const LandlordDashboardScreen()))));
    }

    navItems.add(NavItemData(Icons.person_outline, 'Profile', false, () => Navigator.pushReplacement(context, FadeSlideTransition(page: const ProfileScreen()))));

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
          children: navItems.map((item) => _buildNavItem(item.icon, item.label, item.isActive, onTap: item.onTap)).toList(),
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
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: const BorderRadius.all(Radius.circular(2)))),
              ),
              const SizedBox(height: 24),
              const Text('Bộ lọc tìm kiếm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(_priceRange.start / 1000000).toStringAsFixed(1)} Tr'),
                  Text('${(_priceRange.end / 1000000).toStringAsFixed(1)} Tr'),
                ],
              ),
              RangeSlider(
                values: _priceRange, 
                min: 0, 
                max: 10000000, 
                divisions: 20,
                labels: RangeLabels(
                  '${(_priceRange.start / 1000000).toStringAsFixed(1)} Tr',
                  '${(_priceRange.end / 1000000).toStringAsFixed(1)} Tr',
                ),
                activeColor: AppTheme.primaryColor,
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                  setState(() {});
                }
              ),
              const SizedBox(height: 24),
              const Text('Loại phòng', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  'Tất cả', 'Nhà riêng', 'Căn hộ', 'Ở ghép'
                ].map((cat) => ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) {
                      setModalState(() => _selectedCategory = cat);
                      setState(() {});
                    }
                  },
                )).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Áp dụng bộ lọc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
      side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.black87, fontSize: 12),
    );
  }
}

class NavItemData {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  NavItemData(this.icon, this.label, this.isActive, [this.onTap]);
}
