import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../chat/message_list_screen.dart';
import '../landlord/landlord_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/favorites_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _userRole = doc.data()?['role'] ?? 'user';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Widget> get _screens {
    List<Widget> screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const MessageListScreen(),
    ];

    if (_userRole == 'landlord') {
      screens.add(const LandlordDashboardScreen());
    }

    screens.add(const ProfileScreen());
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex >= _screens.length ? 0 : _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildNavItems(),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    List<NavItemData> items = [
      NavItemData(Icons.search_outlined, Icons.search, 'Khám phá'),
      NavItemData(Icons.favorite_border, Icons.favorite, 'Đã lưu'),
      NavItemData(Icons.chat_bubble_outline, Icons.chat_bubble, 'Tin nhắn'),
    ];

    if (_userRole == 'landlord') {
      items.add(NavItemData(Icons.dashboard_customize_outlined, Icons.dashboard_customize, 'Quản lý'));
    }

    items.add(NavItemData(Icons.person_outline, Icons.person, 'Hồ sơ'));

    return items.asMap().entries.map((entry) {
      int idx = entry.key;
      NavItemData data = entry.value;
      bool isActive = _selectedIndex == idx;

      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = idx),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? data.activeIcon : data.icon,
                color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItemData(this.icon, this.activeIcon, this.label);
}
