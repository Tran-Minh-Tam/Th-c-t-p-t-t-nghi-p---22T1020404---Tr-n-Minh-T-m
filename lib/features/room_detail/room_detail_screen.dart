import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'dart:ui';
import '../map/map_screen.dart';
import '../../core/utils/page_transition.dart';
import '../booking/booking_screen.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';
import '../../widgets/safe_network_image.dart';
import '../../core/config/app_config.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      if (mounted) {
        setState(() {
          _isFavorite = favorites.contains(widget.room.id);
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    if (_isFavorite) {
      await userRef.update({'favorites': FieldValue.arrayRemove([widget.room.id])});
    } else {
      await userRef.update({'favorites': FieldValue.arrayUnion([widget.room.id])});
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Báo cáo vi phạm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Vui lòng cho biết lý do bạn báo cáo bài đăng này:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do báo cáo...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || reasonController.text.trim().isEmpty) return;
                
                await FirebaseFirestore.instance.collection('reports').add({
                  'roomId': widget.room.id,
                  'roomTitle': widget.room.title,
                  'reporterId': user.uid,
                  'reason': reasonController.text.trim(),
                  'status': 'Chưa xử lý',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã báo cáo. Chúng tôi sẽ xem xét ngay.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Gửi báo cáo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('ĐÃ XÁC MINH', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: 0.5)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.deepOrange, size: 14),
                          const SizedBox(width: 4),
                          Text('4.9 (128 Đánh giá)', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.deepOrange, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(widget.room.title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.room.address, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSpecItem('DIỆN TÍCH', '${widget.room.area.toStringAsFixed(0)} m²'),
                          _buildVerticalDivider(),
                          _buildSpecItem('TẦNG', '12'),
                          _buildVerticalDivider(),
                          _buildSpecItem('SỨC CHỨA', '2-3 Người'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildPriceBlock(),
                      const SizedBox(height: 40),
                      Text('Tiện ích nổi bật', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _buildAmenities(),
                      const SizedBox(height: 40),
                      Text('Không gian', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Text(
                        widget.room.description.isEmpty 
                        ? 'Được thiết kế dành cho những người chuyên nghiệp, ${widget.room.title} mang đến trải nghiệm sống tuyệt vời. Với cửa sổ lớn từ sàn đến trần đón ánh sáng tự nhiên và view thành phố tuyệt đẹp.\n\nNội thất bao gồm sàn gỗ cao cấp, nhà bếp với bếp từ hiện đại và hệ thống nhà thông minh.'
                        : widget.room.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blueGrey.withOpacity(0.8), height: 1.7),
                      ),
                      const SizedBox(height: 40),
                      Text('Vị trí', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _buildLocationMap(),
                      const SizedBox(height: 40),
                      _buildReviewsSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildTopBar(),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50, left: 24, right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết vào bộ nhớ tạm')));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.share_outlined, color: AppTheme.primaryColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  _showReportDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : AppTheme.primaryColor, size: 20),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    // Ensure we have at least 3 images for the slider
    List<String> images = List.from(widget.room.images);
    if (images.length < 3) {
      images.addAll([
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80',
      ].take(3 - images.length));
    }

    return SliverAppBar(
      expandedHeight: 350,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return SafeNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
            ),
            // Navigation Arrows
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 36),
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 36),
                  onPressed: () {
                    if (_currentPage < images.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                ),
              ),
            ),
            // Page Indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              bottom: 24, left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                child: const Text('PHÒNG CAO CẤP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primaryContainer)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildPriceBlock() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Giá thuê', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(NumberFormat.currency(locale: 'vi_VN', symbol: '').format(widget.room.price).trim(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 4),
                  const Text('VNĐ/THÁNG', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _buildPriceDetailRow('Phí quản lý', 'Đã bao gồm'),
          const SizedBox(height: 12),
          _buildPriceDetailRow('Điện', '4,000đ/kwh'),
          const SizedBox(height: 12),
          _buildPriceDetailRow('Nước', '100,000đ/người'),
        ],
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryContainer)),
      ],
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildAmenityChip(Icons.wifi_rounded, 'Wifi'),
        _buildAmenityChip(Icons.ac_unit_rounded, 'Điều hòa'),
        _buildAmenityChip(Icons.local_parking_rounded, 'Bãi đỗ xe'),
        _buildAmenityChip(Icons.kitchen_rounded, 'Bếp riêng'),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryContainer)),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    final lat = widget.room.location?.latitude ?? 16.4637;
    final lng = widget.room.location?.longitude ?? 107.5909;
    
    // TrackAsia Static Map URL
    final staticMapUrl = 'https://maps.track-asia.com/api/v1/staticmap'
        '?center=$lat,$lng'
        '&zoom=15'
        '&size=600x300'
        '&key=${AppConfig.googleMapsApiKey}';

    return GestureDetector(
      onTap: () {
        // Convert Google LatLng to latlong2 LatLng for TrackAsia MapScreen
        final trackAsiaLocation = ll.LatLng(lat, lng);
        Navigator.push(context, FadeSlideTransition(page: MapScreen(initialLocation: trackAsiaLocation)));
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              fm.FlutterMap(
                options: fm.MapOptions(
                  initialCenter: ll.LatLng(lat, lng),
                  initialZoom: 15.0,
                  interactionOptions: const fm.InteractionOptions(flags: fm.InteractiveFlag.none),
                ),
                children: [
                  fm.TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  fm.MarkerLayer(
                    markers: [
                      fm.Marker(
                        point: ll.LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              // Overlay to handle tap since interaction is disabled
              Positioned.fill(child: Container(color: Colors.transparent)),
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.navigation_rounded, size: 20, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VỊ TRÍ CHI TIẾT', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            Text('5 phút đến trung tâm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryContainer)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Đánh giá', style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text('4.9', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewCard('Minh Anh', '2 tuần trước', '"Không gian cực kỳ thoáng đãng, ánh sáng tự nhiên rất tốt. Chủ nhà rất nhiệt tình hỗ trợ mình lúc chuyển đến."'),
        _buildReviewCard('James Wilson', '1 tháng trước', '"Great location and very clean. Perfect for remote work with high-speed internet. Highly recommended!"'),
      ],
    );
  }

  Widget _buildReviewCard(String name, String date, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22, 
                backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$name&backgroundColor=b6e3f4'),
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.orange, size: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.blueGrey, fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                peerId: widget.room.landlordId,
                peerName: 'Chủ trọ',
                roomTitle: widget.room.title,
              ))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(room: widget.room))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('Đặt lịch xem phòng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
