import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';
import '../map/map_screen.dart';
import '../../core/utils/page_transition.dart';
import '../booking/booking_screen.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _currentImageIndex = 0;

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
                            child: const Text('ĐÃ XÁC MINH', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, size: 4, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.deepOrange, size: 12),
                          const SizedBox(width: 4),
                          const Text('4.9 (128 Đánh giá)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(widget.room.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.room.address, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      _buildPriceBlock(),
                      const SizedBox(height: 32),
                      const Text('Tiện ích nổi bật', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildAmenities(),
                      const SizedBox(height: 32),
                      const Text('Không gian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        widget.room.description.isEmpty 
                        ? 'Được thiết kế dành cho những người chuyên nghiệp, ${widget.room.title} mang đến trải nghiệm sống tuyệt vời. Với cửa sổ lớn từ sàn đến trần đón ánh sáng tự nhiên và view thành phố tuyệt đẹp.\n\nNội thất bao gồm sàn gỗ cao cấp, nhà bếp với bếp từ hiện đại và hệ thống nhà thông minh. Cư dân còn được sử dụng hồ bơi vô cực, lễ tân 24/7 và khu vực làm việc chung.'
                        : widget.room.description,
                        style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      const Text('Đọc thêm chi tiết v', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      const Text('Vị trí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildLocationMap(),
                      const SizedBox(height: 32),
                      _buildReviewsSection(),
                      const SizedBox(height: 100),
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
                child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              const Text('The Sanctuary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.share, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  widget.room.images.isNotEmpty ? widget.room.images[0] : 'https://placehold.co/600',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 120, left: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
                child: const Text('PHÒNG CAO CẤP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30, color: Colors.grey.shade300);
  }

  Widget _buildPriceBlock() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Giá thuê', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(NumberFormat.currency(locale: 'vi_VN', symbol: '').format(widget.room.price).trim(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(' VNĐ', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phí quản lý', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Đã bao gồm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Điện', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('4,000đ/kwh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAmenityChip(Icons.wifi, 'Wifi Miễn phí'),
        _buildAmenityChip(Icons.ac_unit, 'Điều hòa'),
        _buildAmenityChip(Icons.local_parking, 'Chỗ để xe'),
        _buildAmenityChip(Icons.kitchen, 'Nhà bếp'),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF88B3B5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.location_on, size: 80, color: Colors.red.shade700),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFE0EBEB), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.directions_walk, size: 16, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GẦN ĐÂY', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('5 phút đến Chợ Bến Thành', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(16)),
                    child: const Text('Mở\nBản đồ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text('4.9', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.deepOrange, size: 12))),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewCard('Minh Anh', 'Tháng 10 2023', '"Không gian còn đẹp hơn trên ảnh! View buổi tối cực kỳ tuyệt vời. Chủ nhà hỗ trợ rất nhiệt tình. Rất đáng trải nghiệm!"'),
        _buildReviewCard('James Wilson', 'Tháng 9 2023', '"Vị trí tuyệt vời và rất sạch sẽ. Tốc độ mạng wifi hoàn hảo cho làm việc từ xa. Điểm trừ duy nhất là phải chờ lấy xe, nhưng tổng thể 10/10."'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text('Xem tất cả 128 đánh giá', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String name, String date, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.deepOrange, size: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
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
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                  ),
                  child: const Text('Đặt lịch xem phòng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
