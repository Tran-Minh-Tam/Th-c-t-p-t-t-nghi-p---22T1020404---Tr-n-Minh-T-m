import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../chat/message_list_screen.dart';
import '../auth/login_screen.dart';
import '../../core/utils/page_transition.dart';
import '../landlord/create_room_screen.dart';
import '../landlord/manage_rooms_screen.dart';
import '../landlord/manage_bookings_screen.dart';
import '../booking/my_bookings_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'Đang tải...';
  String _role = 'user';
  String _avatarUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _fullName = doc.data()?['fullName'] ?? 'Người dùng';
            _role = doc.data()?['role'] ?? 'user';
            _avatarUrl = doc.data()?['avatarUrl'] ?? '';
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
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
              const Divider(height: 1, color: Color(0xFFF0F4F4)),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 120),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 40),
                          if (_role == 'landlord') ...[
                            _buildLandlordSection(),
                            const SizedBox(height: 32),
                          ],
                          _buildMyActivity(),
                          const SizedBox(height: 16),
                          _buildPreferences(),
                          const SizedBox(height: 32),
                          _buildLogOutButton(),
                        ],
                      ),
                    ),
              ),
            ],
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.menu, color: AppTheme.primaryContainer),
              SizedBox(width: 16),
              Text(
                'SANCTUARY',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
                image: DecorationImage(
                  image: NetworkImage(_avatarUrl.isNotEmpty ? _avatarUrl : 'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
                ],
                image: DecorationImage(
                  image: NetworkImage(_avatarUrl.isNotEmpty ? _avatarUrl : 'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _fullName,
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _role == 'landlord' ? const Color(0xFFDBEAFE) : const Color(0xFFFFDBC8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _role == 'landlord' ? 'CHỦ TRỌ' : 'THÀNH VIÊN VIP',
            style: TextStyle(
              color: _role == 'landlord' ? Colors.blue.shade900 : AppTheme.tertiaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandlordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUẢN LÝ CHO THUÊ',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6E797A)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                Icons.add_business_outlined, 
                'Đăng tin mới', 
                AppTheme.primaryColor.withValues(alpha: 0.1), 
                AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRoomScreen()));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                Icons.list_alt_rounded, 
                'Tin đã đăng', 
                Colors.orange.withValues(alpha: 0.1), 
                Colors.orange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRoomsScreen()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          Icons.event_note_rounded, 
          'Quản lý lịch hẹn của khách', 
          Colors.green.withValues(alpha: 0.1), 
          Colors.green,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageBookingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDC9C9).withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
          ],
        ),
      ),
    );
  }

  Widget _buildMyActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOẠT ĐỘNG CỦA TÔI',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6E797A)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActivityCard(
                Icons.favorite, 
                'Phòng đã lưu', 
                'Xem', 
                const Color(0xFFC3E6E8), 
                AppTheme.secondaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivityCard(
                Icons.history, 
                'Lịch hẹn của tôi', 
                'Xem', 
                AppTheme.primaryColor.withValues(alpha: 0.1), 
                AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(IconData icon, String label, String value, Color iconBgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDC9C9).withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3E4949))),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÀI ĐẶT',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6E797A)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildPreferenceItem(Icons.person, 'Thông tin tài khoản'),
              _buildPreferenceItem(Icons.notifications, 'Thông báo'),
              _buildPreferenceItem(Icons.shield, 'Quyền riêng tư & Bảo mật'),
              _buildDarkModeToggle(),
              _buildPreferenceItem(Icons.help_center, 'Trợ giúp & Hỗ trợ'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6E797A)),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6E797A)),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    bool isDark = ThemeManager.themeMode.value == ThemeMode.dark;

    return Container(
      color: isDark ? Colors.black26 : const Color(0xFFE5E9E9).withValues(alpha: 0.4),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.dark_mode, color: Color(0xFF6E797A)),
              SizedBox(width: 16),
              Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Switch(
            value: isDark,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                ThemeManager.toggleTheme(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogOutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFF93000A)),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFF93000A), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Khám phá', false, onTap: () {
              Navigator.pushReplacement(context, FadeSlideTransition(page: const HomeScreen()));
            }),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false),
            _buildNavItem(Icons.chat_bubble_outline, 'Hộp thư', false, onTap: () {
              Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()));
            }),
            _buildNavItem(Icons.person, 'Cá nhân', true),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryContainer : const Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: isActive ? AppTheme.primaryContainer : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
