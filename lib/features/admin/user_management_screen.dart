import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = '';
  String _filterRole = 'Tất cả';

  final List<String> _roles = ['Tất cả', 'admin', 'landlord', 'user'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Người dùng',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;

                // Apply filters
                if (_filterRole != 'Tất cả') {
                  users = users
                      .where((doc) =>
                          (doc.data() as Map<String, dynamic>)['role'] == _filterRole)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  users = users.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        (data['fullName'] ?? data['name'] ?? '').toLowerCase();
                    final email = (data['email'] ?? '').toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) ||
                        email.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Không tìm thấy người dùng',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildUserCard(context, doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc email...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final role = _roles[i];
                final isSelected = _filterRole == role;
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        role == 'Tất cả'
                            ? 'Tất cả'
                            : role == 'admin'
                                ? 'Admin'
                                : role == 'landlord'
                                    ? 'Chủ trọ'
                                    : 'Người thuê',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, String uid, Map<String, dynamic> data) {
    final role = data['role'] ?? 'user';
    final isBlocked = data['isBlocked'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBlocked ? Colors.red.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
        border: isBlocked
            ? Border.all(color: Colors.red.withValues(alpha: 0.15))
            : null,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _roleColor(role).withValues(alpha: 0.1),
                child: Text(
                  (data['fullName'] ?? data['name'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                      color: _roleColor(role),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              if (isBlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['fullName'] ?? data['name'] ?? 'Người dùng',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildRoleBadge(role),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['email'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isBlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('⚠ Tài khoản đã bị khóa',
                        style: TextStyle(color: Colors.red, fontSize: 11)),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, uid, value),
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'set_admin',
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings, size: 18, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Đặt làm Admin'),
                  ])),
              const PopupMenuItem(
                  value: 'set_landlord',
                  child: Row(children: [
                    Icon(Icons.home_work, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Đặt làm Chủ trọ'),
                  ])),
              const PopupMenuItem(
                  value: 'set_user',
                  child: Row(children: [
                    Icon(Icons.person, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Đặt làm Người thuê'),
                  ])),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: isBlocked ? 'unblock' : 'block',
                child: Row(children: [
                  Icon(
                    isBlocked ? Icons.lock_open : Icons.lock,
                    size: 18,
                    color: isBlocked ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBlocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                    style: TextStyle(
                        color: isBlocked ? Colors.green : Colors.red),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;
    switch (role) {
      case 'admin':
        color = Colors.purple;
        label = 'Admin';
        break;
      case 'landlord':
        color = Colors.blue;
        label = 'Chủ trọ';
        break;
      default:
        color = Colors.green;
        label = 'Người thuê';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'landlord':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _handleAction(BuildContext context, String uid, String action) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    switch (action) {
      case 'set_admin':
        await ref.update({'role': 'admin'});
        break;
      case 'set_landlord':
        await ref.update({'role': 'landlord'});
        break;
      case 'set_user':
        await ref.update({'role': 'user'});
        break;
      case 'block':
        await ref.update({'isBlocked': true});
        break;
      case 'unblock':
        await ref.update({'isBlocked': false});
        break;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green),
      );
    }
  }
}
