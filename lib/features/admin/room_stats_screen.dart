import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RoomStatsScreen extends StatelessWidget {
  const RoomStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thống kê & Báo cáo', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartCard('Số lượng phòng theo tháng', [0.4, 0.6, 0.5, 0.8, 0.7, 0.9]),
            const SizedBox(height: 24),
            _buildChartCard('Người dùng mới đăng ký', [0.3, 0.5, 0.4, 0.6, 0.8, 0.5]),
            const SizedBox(height: 24),
            _buildSummaryTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, List<double> values) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.bottom,
              children: values.map((v) => _buildBar(v)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'].map((m) => Text(m, style: TextStyle(color: Colors.grey, fontSize: 10))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 32,
      height: 150 * heightFactor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top khu vực nhu cầu cao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildTableRow('Phường Vĩnh Ninh', '145 phòng', 'High'),
          _buildTableRow('Phường Phú Nhuận', '98 phòng', 'Medium'),
          _buildTableRow('Phường Xuân Phú', '82 phòng', 'Medium'),
          _buildTableRow('Phường Vỹ Dạ', '65 phòng', 'Low'),
        ],
      ),
    );
  }

  Widget _buildTableRow(String area, String count, String demand) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(area, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(count, style: const TextStyle(color: Colors.grey)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: demand == 'High' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(demand, style: TextStyle(fontSize: 10, color: demand == 'High' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
