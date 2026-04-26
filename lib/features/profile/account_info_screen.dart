import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc.data()?['fullName'] ?? '';
          _phoneController.text = doc.data()?['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('THÔNG TIN TÀI KHOẢN', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: const ClipOval(
                      child: Icon(Icons.person, size: 60, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  Positioned(
                    bottom: 4, right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'THÔNG TIN CƠ BẢN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            const Text(
              'TÀI KHOẢN LIÊN KẾT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'Không có email',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.verified, color: Colors.green, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
              prefixIcon: Icon(icon, color: AppTheme.primaryContainer, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
      ],
    );
  }
}
