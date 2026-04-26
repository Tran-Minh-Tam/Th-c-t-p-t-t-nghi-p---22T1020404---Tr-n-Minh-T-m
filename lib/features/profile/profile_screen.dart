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
import 'account_info_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';

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
        } else {
          setState(() {
            _fullName = 'Người dùng';
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        setState(() {
          _fullName = 'Người dùng';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _fullName = 'Khách';
        _isLoading = false;
      });
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        _buildTopAppBar(),
                        _buildProfileHeader(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMyActivity(),
                              const SizedBox(height: 24),
                              _buildPreferences(),
                              const SizedBox(height: 32),
                              _buildLogOutButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: AppTheme.primaryContainer),
              const SizedBox(width: 16),
              const Text(
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(_avatarUrl.isNotEmpty ? _avatarUrl : 'https://placehold.co/100'),
                fit: BoxFit.cover,
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                ],
                image: DecorationImage(
                  image: NetworkImage(_avatarUrl.isNotEmpty ? _avatarUrl : 'https://placehold.co/400'),
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
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _fullName == 'Người dùng' ? 'Elena Rodriguez' : _fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0D2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _role == 'landlord' ? 'CHỦ TRỌ' : 'THÀNH VIÊN CAO CẤP',
            style: const TextStyle(
              color: Colors.deepOrange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOẠT ĐỘNG CỦA TÔI',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActivityCard(
                Icons.favorite, 
                'Phòng đã lưu', 
                '14', 
                const Color(0xFFE8F4F5), 
                const Color(0xFF4A6B6C),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivityCard(
                Icons.history, 
                'Tin đã xem', 
                '42', 
                const Color(0xFFE8F4F5), 
                const Color(0xFF4A6B6C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(IconData icon, String label, String value, Color iconBgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÀI ĐẶT',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildPreferenceItem(Icons.person, 'Thông tin tài khoản', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen()))),
              _buildDivider(),
              _buildPreferenceItem(Icons.notifications, 'Thông báo', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()))),
              _buildDivider(),
              _buildPreferenceItem(Icons.shield, 'Quyền riêng tư & Bảo mật', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()))),
              _buildDivider(),
              _buildDarkModeToggle(),
              _buildDivider(),
              _buildPreferenceItem(Icons.help_center, 'Trợ giúp & Hỗ trợ', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.black12, indent: 48, endIndent: 16);
  }

  Widget _buildPreferenceItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54, size: 20),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    bool isDark = ThemeManager.themeMode.value == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.dark_mode, color: Colors.black54, size: 20),
              const SizedBox(width: 12),
              const Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
          color: const Color(0xFFFFE4E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFF8B0000), size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.bold, fontSize: 16),
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
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Khám phá', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const HomeScreen()))),
            _buildNavItem(Icons.favorite_border, 'Đã lưu', false, onTap: () => Navigator.push(context, FadeSlideTransition(page: const FavoritesScreen()))),
            _buildNavItem(Icons.chat_bubble_outline, 'Tin nhắn', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const MessageListScreen()))),
            if (_role == 'landlord')
              _buildNavItem(Icons.dashboard_customize, 'Quản lý', false, onTap: () => Navigator.pushReplacement(context, FadeSlideTransition(page: const LandlordDashboardScreen()))),
            _buildNavItem(Icons.person, 'Hồ sơ', true),
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
              color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
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
              color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
