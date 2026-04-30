import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = '';
  String _filterRole = 'Tất cả';

  final List<String> _roles = ['Tất cả', 'Chủ trọ', 'Người thuê'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Người dùng', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _roles.map((role) {
                final isSelected = _filterRole == role;
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = role),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
                    ),
                    child: Text(role, style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var users = snapshot.data!.docs;

                if (_filterRole != 'Tất cả') {
                  String roleCode = _filterRole == 'Chủ trọ' ? 'landlord' : 'user';
                  users = users.where((doc) => (doc.data() as Map<String, dynamic>)['role'] == roleCode).toList();
                }
                
                if (_searchQuery.isNotEmpty) {
                  users = users.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['fullName'] ?? data['name'] ?? '').toLowerCase();
                    final email = (data['email'] ?? '').toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                if (users.isEmpty) {
                  return const Center(child: Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
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

  Widget _buildUserCard(BuildContext context, String uid, Map<String, dynamic> data) {
    final role = data['role'] ?? 'user';
    final isBlocked = data['isBlocked'] ?? false;
    
    String roleName = role == 'admin' ? 'Admin' : (role == 'landlord' ? 'Chủ trọ' : 'Người thuê');
    Color roleColor = role == 'admin' ? Colors.purple : (role == 'landlord' ? Colors.blue : Colors.green);

    String joinDate = 'Không rõ';
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        joinDate = DateFormat('dd/MM/yyyy').format((data['createdAt'] as Timestamp).toDate());
      } else if (data['createdAt'] is String) {
        try {
          joinDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['createdAt']));
        } catch (_) {}
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$uid&backgroundColor=b6e3f4'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(data['fullName'] ?? data['name'] ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(roleName, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Tham gia từ: $joinDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: !isBlocked,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.red,
            onChanged: (value) => _toggleBlockStatus(context, uid, !value),
          ),
        ],
      ),
    );
  }

  void _toggleBlockStatus(BuildContext context, String uid, bool block) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'isBlocked': block});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(block ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'), backgroundColor: block ? Colors.red : Colors.green));
    }
  }
}
