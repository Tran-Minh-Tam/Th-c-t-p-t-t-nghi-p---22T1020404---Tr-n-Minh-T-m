import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('CÀI ĐẶT THÔNG BÁO', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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
              'CẤU HÌNH NHẬN TIN',
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
                  _buildNotificationItem(
                    title: 'Thông báo đẩy',
                    subtitle: 'Tin nhắn, lịch hẹn, cập nhật phòng',
                    value: pushEnabled,
                    onChanged: (v) => setState(() => pushEnabled = v),
                    icon: Icons.notifications_active_outlined,
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    title: 'Thông báo Email',
                    subtitle: 'Bản tin, ưu đãi, báo cáo tháng',
                    value: emailEnabled,
                    onChanged: (v) => setState(() => emailEnabled = v),
                    icon: Icons.mail_outline,
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    title: 'Âm thanh & Rung',
                    subtitle: 'Phát âm thanh khi có thông báo mới',
                    value: true,
                    onChanged: (v) {},
                    icon: Icons.volume_up_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'QUẢN LÝ CHỦ ĐỀ',
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
                  _buildNotificationItem(
                    title: 'Tin nhắn mới',
                    subtitle: 'Thông báo khi có người nhắn tin cho bạn',
                    value: true,
                    onChanged: (v) {},
                    icon: Icons.chat_bubble_outline,
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    title: 'Lịch hẹn xem phòng',
                    subtitle: 'Thông báo nhắc nhở lịch hẹn sắp tới',
                    value: true,
                    onChanged: (v) {},
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({required String title, required String subtitle, required bool value, required Function(bool) onChanged, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value, 
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 64, endIndent: 16);
  }
}
