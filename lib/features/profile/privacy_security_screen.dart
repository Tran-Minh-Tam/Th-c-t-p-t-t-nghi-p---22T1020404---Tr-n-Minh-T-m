import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('QUYỀN RIÊNG TƯ & BẢO MẬT', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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
            const Text(
              'TÀI KHOẢN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildSecurityItem(
                    context, 
                    Icons.lock_outline, 
                    'Đổi mật khẩu', 
                    'Cập nhật mật khẩu để bảo vệ tài khoản',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _buildDivider(),
                  _buildSecurityItem(
                    context, 
                    Icons.fingerprint, 
                    'Xác thực sinh trắc học', 
                    'Sử dụng vân tay hoặc khuôn mặt',
                    trailing: Switch(value: false, onChanged: (v) {}, activeColor: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'QUYỀN RIÊNG TƯ',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildSecurityItem(
                    context, 
                    Icons.visibility_off_outlined, 
                    'Chế độ ẩn danh', 
                    'Ẩn trạng thái hoạt động của bạn',
                    trailing: Switch(value: false, onChanged: (v) {}, activeColor: AppTheme.primaryColor),
                  ),
                  _buildDivider(),
                  _buildSecurityItem(
                    context, 
                    Icons.history, 
                    'Xóa lịch sử tìm kiếm', 
                    'Xóa mọi dữ liệu tìm kiếm gần đây',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'DỮ LIỆU',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildSecurityItem(
                context, 
                Icons.delete_outline, 
                'Xóa tài khoản', 
                'Xóa vĩnh viễn dữ liệu và tài khoản',
                titleColor: const Color(0xFF8B0000),
                iconColor: const Color(0xFF8B0000),
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(BuildContext context, IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap, Color? titleColor, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryContainer).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryContainer, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor ?? Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 64, endIndent: 16);
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tài khoản?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hành động này không thể hoàn tác. Mọi dữ liệu của bạn sẽ bị xóa vĩnh viễn khỏi hệ thống.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yêu cầu đã được gửi. Chúng tôi sẽ xử lý trong 24h.'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPasswordField(oldPasswordController, 'Mật khẩu hiện tại'),
                    const SizedBox(height: 16),
                    _buildPasswordField(newPasswordController, 'Mật khẩu mới'),
                    const SizedBox(height: 16),
                    _buildPasswordField(confirmPasswordController, 'Xác nhận mật khẩu mới'),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ]
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (newPasswordController.text != confirmPasswordController.text) {
                            setState(() => errorMessage = 'Mật khẩu mới không khớp!');
                            return;
                          }
                          if (newPasswordController.text.length < 6) {
                            setState(() => errorMessage = 'Mật khẩu phải từ 6 ký tự!');
                            return;
                          }
                          setState(() { isLoading = true; errorMessage = null; });
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.email != null) {
                              AuthCredential credential = EmailAuthProvider.credential(
                                email: user.email!, 
                                password: oldPasswordController.text
                              );
                              await user.reauthenticateWithCredential(credential);
                              await user.updatePassword(newPasswordController.text);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
                                );
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              isLoading = false;
                              if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                errorMessage = 'Mật khẩu hiện tại không chính xác!';
                              } else {
                                errorMessage = e.message;
                              }
                            });
                          } catch (e) {
                            setState(() { isLoading = false; errorMessage = 'Lỗi: $e'; });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : const Text('Cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
