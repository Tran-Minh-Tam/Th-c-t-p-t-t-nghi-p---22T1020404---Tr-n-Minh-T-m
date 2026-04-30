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
import 'viewed_rooms_screen.dart';
import 'account_info_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../../core/widgets/avatar_widget.dart';
import '../home/main_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'Đang tải...';
  String _role = 'user';
  String _avatarUrl = '';
  String _avatarType = 'default';
  bool _isLoading = true;
  int _favoriteCount = 0;
  int _viewedCount = 0;

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
          final favorites = doc.data()?['favorites'] as List<dynamic>? ?? [];
          final viewed = doc.data()?['viewedRooms'] as List<dynamic>? ?? [];
          setState(() {
            _fullName = doc.data()?['fullName'] ?? 'Người dùng';
            _role = doc.data()?['role'] ?? 'user';
            _avatarUrl = doc.data()?['avatarUrl'] ?? '';
            _avatarType = doc.data()?['avatarType'] ?? 'default';
            _favoriteCount = favorites.length;
            _viewedCount = viewed.length;
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
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
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
              Text(
                'TAM RENTED ROOM',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          AvatarWidget(
            imageUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
            avatarType: _avatarType == 'default' ? null : _avatarType,
            radius: 16,
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
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                  ],
                ),
                child: AvatarWidget(
                  imageUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
                  avatarType: _avatarType == 'default' ? null : _avatarType,
                  radius: 56,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _showAvatarPicker,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
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
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
                child: _buildActivityCard(
                  Icons.favorite,
                  'Phòng đã lưu',
                  _favoriteCount.toString(),
                  const Color(0xFFE8F4F5),
                  const Color(0xFF4A6B6C),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewedRoomsScreen())),
                child: _buildActivityCard(
                  Icons.history,
                  'Tin đã xem',
                  _viewedCount.toString(),
                  const Color(0xFFE8F4F5),
                  const Color(0xFF4A6B6C),
                ),
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

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => AvatarPicker(
        currentAvatarType: _avatarType,
        onAvatarSelected: (String avatarType) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'avatarType': avatarType,
              });
              setState(() {
                _avatarType = avatarType;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không thể cập nhật ảnh đại diện')),
              );
            }
          }
        },
      ),
    );
  }

}
