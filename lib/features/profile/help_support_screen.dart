import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('TRỢ GIÚP & HỖ TRỢ', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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
              'CÂU HỎI THƯỜNG GẶP (FAQ)',
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
                  _buildFaqItem('Làm sao để đăng bài tìm chủ trọ?', 'Bạn có thể chuyển sang tài khoản Chủ trọ trong mục "Hồ sơ" và nhấn vào biểu tượng "+" hoặc "Đăng tin mới" ở màn hình Quản lý.'),
                  _buildDivider(),
                  _buildFaqItem('Làm sao để liên hệ với người cho thuê?', 'Bạn có thể nhấn vào nút "Nhắn tin" ngay tại màn hình chi tiết phòng hoặc gọi trực tiếp qua số hotline được cung cấp.'),
                  _buildDivider(),
                  _buildFaqItem('Ứng dụng có thu phí không?', 'Ứng dụng hoàn toàn miễn phí cho người tìm phòng. Đối với chủ trọ, chúng tôi có các gói dịch vụ đẩy tin ưu tiên.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'LIÊN HỆ VỚI CHÚNG TÔI',
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
                  _buildContactItem(Icons.email_outlined, 'Gửi email hỗ trợ', 'support@sanctuary.vn'),
                  _buildDivider(),
                  _buildContactItem(Icons.phone_outlined, 'Tổng đài Hotline', '1900 1234 (8:00 - 22:00)'),
                  _buildDivider(),
                  _buildContactItem(Icons.public_outlined, 'Website chính thức', 'www.sanctuary.vn'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cần hỗ trợ gấp?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Chat trực tiếp với đội ngũ tư vấn của chúng tôi.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      iconColor: AppTheme.primaryColor,
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(answer, style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16);
  }
}
