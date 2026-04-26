import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class RoomStatsScreen extends StatefulWidget {
  const RoomStatsScreen({super.key});

  @override
  State<RoomStatsScreen> createState() => _RoomStatsScreenState();
}

class _RoomStatsScreenState extends State<RoomStatsScreen> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalRooms = 0;
  int _totalBookings = 0;
  int _totalReports = 0;
  List<Map<String, dynamic>> _topLandlords = [];
  List<Map<String, dynamic>> _topAreas = [];
  // Monthly room counts for the last 6 months
  List<double> _monthlyRooms = List.filled(6, 0);
  List<double> _monthlyUsers = List.filled(6, 0);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final db = FirebaseFirestore.instance;

      // Totals
      final usersSnap = await db.collection('users').get();
      final roomsSnap = await db.collection('rooms').get();
      final bookingsSnap = await db.collection('bookings').get();
      final reportsSnap = await db.collection('reports').get();

      // Monthly data — last 6 months
      final now = DateTime.now();
      final monthlyRooms = List<double>.filled(6, 0);
      final monthlyUsers = List<double>.filled(6, 0);

      for (final doc in roomsSnap.docs) {
        final data = doc.data();
        final ts = data['createdAt'];
        if (ts is Timestamp) {
          final date = ts.toDate();
          for (int i = 0; i < 6; i++) {
            final month = DateTime(now.year, now.month - i, 1);
            if (date.year == month.year && date.month == month.month) {
              monthlyRooms[5 - i]++;
              break;
            }
          }
        }
      }

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final ts = data['createdAt'];
        if (ts is Timestamp) {
          final date = ts.toDate();
          for (int i = 0; i < 6; i++) {
            final month = DateTime(now.year, now.month - i, 1);
            if (date.year == month.year && date.month == month.month) {
              monthlyUsers[5 - i]++;
              break;
            }
          }
        }
      }

      // Top landlords by room count
      final Map<String, int> landlordRoomCount = {};
      final Map<String, String> landlordNames = {};
      for (final doc in roomsSnap.docs) {
        final data = doc.data();
        final lid = data['landlordId'] as String? ?? '';
        if (lid.isNotEmpty) {
          landlordRoomCount[lid] = (landlordRoomCount[lid] ?? 0) + 1;
        }
      }
      for (final uid in landlordRoomCount.keys) {
        try {
          final uDoc = await db.collection('users').doc(uid).get();
          landlordNames[uid] = uDoc.data()?['fullName'] ?? 'Chủ trọ';
        } catch (_) {
          landlordNames[uid] = 'Chủ trọ';
        }
      }
      final topLandlords = landlordRoomCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topLandlordsData = topLandlords.take(5).map((e) => {
        'name': landlordNames[e.key] ?? 'Chủ trọ',
        'count': e.value,
      }).toList();

      // Top areas by room count
      final Map<String, int> areaCount = {};
      for (final doc in roomsSnap.docs) {
        final data = doc.data();
        final address = data['address'] as String? ?? '';
        // Extract district/city part
        final parts = address.split(',');
        final area = parts.length > 1 ? parts[parts.length - 1].trim() : address;
        if (area.isNotEmpty) {
          areaCount[area] = (areaCount[area] ?? 0) + 1;
        }
      }
      final topAreas = areaCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topAreasData = topAreas.take(5).map((e) => {
        'name': e.key,
        'count': e.value,
      }).toList();

      if (mounted) {
        setState(() {
          _totalUsers = usersSnap.docs.length;
          _totalRooms = roomsSnap.docs.length;
          _totalBookings = bookingsSnap.docs.length;
          _totalReports = reportsSnap.docs.length;
          _monthlyRooms = monthlyRooms;
          _monthlyUsers = monthlyUsers;
          _topLandlords = topLandlordsData;
          _topAreas = topAreasData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thống kê & Báo cáo',
            style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 24),
                    _buildChartCard(
                      'Phòng trọ đăng mới theo tháng',
                      _monthlyRooms,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildChartCard(
                      'Người dùng mới đăng ký theo tháng',
                      _monthlyUsers,
                      Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    _buildTopAreasTable(),
                    const SizedBox(height: 24),
                    _buildTopLandlordsTable(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Người dùng', Icons.people, Colors.blue, _totalUsers.toString()),
        _buildStatCard('Phòng trọ', Icons.home, Colors.green, _totalRooms.toString()),
        _buildStatCard('Lịch hẹn', Icons.event_available, Colors.orange, _totalBookings.toString()),
        _buildStatCard('Báo cáo', Icons.report_problem, Colors.red, _totalReports.toString()),
      ],
    );
  }

  Widget _buildStatCard(String label, IconData icon, Color color, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, List<double> values, Color barColor) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final normalizedValues = maxVal == 0
        ? List<double>.filled(values.length, 0.05)
        : values.map((v) => v == 0 ? 0.05 : v / maxVal).toList();

    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return 'T${m.month}';
    });

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
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(6, (i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      values[i].toInt().toString(),
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 130 * normalizedValues[i],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [barColor, barColor.withValues(alpha: 0.5)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: months
                .map((m) => Text(m, style: const TextStyle(color: Colors.grey, fontSize: 10)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAreasTable() {
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
          const Text('Top khu vực nhu cầu cao',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (_topAreas.isEmpty)
            const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey)))
          else
            ...List.generate(_topAreas.length, (i) {
              final area = _topAreas[i];
              final demand = i == 0 ? 'Cao' : (i == 1 ? 'Vừa' : 'Thấp');
              final demandColor = i == 0 ? Colors.green : (i == 1 ? Colors.orange : Colors.grey);
              return _buildAreaRow(area['name'], '${area['count']} phòng', demand, demandColor);
            }),
        ],
      ),
    );
  }

  Widget _buildAreaRow(String area, String count, String demand, Color demandColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(area, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(count, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: demandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(demand,
                style: TextStyle(fontSize: 10, color: demandColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLandlordsTable() {
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
          const Text('Top chủ trọ hoạt động',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (_topLandlords.isEmpty)
            const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey)))
          else
            ...List.generate(_topLandlords.length, (i) {
              final landlord = _topLandlords[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? Colors.amber.withValues(alpha: 0.2)
                            : AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: i == 0 ? Colors.amber.shade800 : AppTheme.primaryColor,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(landlord['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Text('${landlord['count']} phòng',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
