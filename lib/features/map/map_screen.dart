import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../room_detail/room_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/room_model.dart';
import '../../core/config/app_config.dart';
import '../../widgets/safe_network_image.dart';

class MapScreen extends StatefulWidget {
  final ll.LatLng? initialLocation;
  const MapScreen({super.key, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Room> _rooms = [];
  bool _isLoading = true;

  // Center coordinate (Default: Hue City)
  static final ll.LatLng _defaultCenter = ll.LatLng(16.4637, 107.5909);

  @override
  void initState() {
    super.initState();
    _fetchAndInitMarkers();
  }

  Future<void> _fetchAndInitMarkers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('rooms')
          .where('status', isEqualTo: 'Đã duyệt')
          .get();
      _rooms = snap.docs.map((doc) => Room.fromFirestore(doc)).toList();
      
      if (mounted) {
          setState(() {
            _markers = _rooms.asMap().entries.map((entry) {
              final i = entry.key;
              final room = entry.value;
              
              // Tạo độ lệch ngẫu nhiên nhưng cố định theo index để tránh bị nhảy vị trí liên tục
              final random = math.Random(room.id.hashCode);
              final latOffset = (random.nextDouble() - 0.5) * 0.03;
              final lngOffset = (random.nextDouble() - 0.5) * 0.03;

              final lat = (room.location?.latitude ?? _defaultCenter.latitude) + latOffset;
              final lng = (room.location?.longitude ?? _defaultCenter.longitude) + lngOffset;
              final pos = ll.LatLng(lat, lng);
              
              // Update the room's location locally so the bottom list onTap matches the scatter!
              _rooms[i] = Room(
                id: room.id, title: room.title, description: room.description,
                price: room.price, address: room.address, area: room.area,
                images: room.images, category: room.category, rating: room.rating,
                landlordId: room.landlordId, status: room.status, isFeatured: room.isFeatured,
                location: LatLng(lat, lng), // Use the scattered lat/lng (import google_maps_flutter LatLng)
              );

              return Marker(
                point: pos,
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                        ),
                        child: Text(
                          '${(room.price / 1000000).toStringAsFixed(1)} Tr',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 30),
                    ],
                  ),
                ),
              );
            }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? _defaultCenter,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Custom Search Bar on Top
          Positioned(
            top: 50,
            left: 70,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm khu vực...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Room List at Bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return GestureDetector(
                  onTap: () {
                    final lat = room.location?.latitude ?? _defaultCenter.latitude;
                    final lng = room.location?.longitude ?? _defaultCenter.longitude;
                    _mapController.move(ll.LatLng(lat, lng), 15.0);
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SafeNetworkImage(
                            imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/100',
                            width: 80, height: 80, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('${(room.price / 1000000).toStringAsFixed(1)} Tr/tháng', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  Text(' ${room.rating}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
