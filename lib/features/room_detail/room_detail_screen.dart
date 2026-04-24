import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';
import '../map/map_screen.dart';
import '../../core/utils/page_transition.dart';
import '../booking/booking_screen.dart';
import '../chat/chat_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: _buildCircleButton(
                  context,
                  Icons.arrow_back_ios_new,
                  () => Navigator.pop(context),
                ),
                actions: [
                  _buildCircleButton(
                    context,
                    Icons.share_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép liên kết phòng trọ!')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCircleButton(
                    context,
                    Icons.favorite_border,
                    () {},
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'room_image_${room.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          room.images.isNotEmpty ? room.images[0] : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              room.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                room.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        room.title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF6E797A), size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room.address,
                              style: const TextStyle(color: Color(0xFF6E797A), fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSpecItem(Icons.square_foot, '${room.area} m²', 'Diện tích'),
                          _buildSpecItem(Icons.bed_outlined, '1 PN', 'Phòng ngủ'),
                          _buildSpecItem(Icons.bathtub_outlined, '1 WC', 'Phòng tắm'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Mô tả',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        room.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3E4949),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAmenities(),
                      _buildMap(context),
                      _buildReviews(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Color(0xFF6E797A), fontSize: 12)),
      ],
    );
  }

  Widget _buildAmenities() {
    final amenities = ['Wifi miễn phí', 'Điều hòa', 'Tủ lạnh', 'Chỗ để xe', 'Tự do'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiện ích',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: amenities.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBDC9C9).withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          initialLocation: LatLng(room.location?.latitude ?? 16.4637, room.location?.longitude ?? 107.5909),
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=${room.location?.latitude ?? 16.4637},${room.location?.longitude ?? 107.5909}&zoom=15&size=600x300&markers=color:red%7C${room.location?.latitude ?? 16.4637},${room.location?.longitude ?? 107.5909}&key=AIzaSyDa37dJItkPjLqBsY6Dh7gOpuUGApVwmfs',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Note: In real app, use url_launcher
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                const Text('4.9', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (index) => const Icon(Icons.star, color: AppTheme.primaryColor, size: 16)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewCard('Minh Anh', 'Tháng 10, 2023', '"Không gian còn đẹp hơn cả trong ảnh! View ban đêm cực kỳ xịn xò."'),
        const SizedBox(height: 16),
        _buildReviewCard('Hoàng Nam', 'Tháng 9, 2023', '"Vị trí thuận tiện và rất sạch sẽ. Tốc độ internet hoàn hảo cho công việc."'),
      ],
    );
  }

  Widget _buildReviewCard(String name, String date, String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBDC9C9).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFFE5E9E9), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF6E797A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: Border(top: BorderSide(color: const Color(0xFFBDC9C9).withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peerId: room.landlordId,
                          peerName: 'Chủ trọ ${room.landlordId}',
                          roomTitle: room.title,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(room: room),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Đặt lịch ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryContainer, size: 20),
      ),
    );
  }
}
