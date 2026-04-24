import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../room_detail/room_detail_screen.dart';
import '../../data/services/api_service.dart';
import '../../data/models/room_model.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const MapScreen({super.key, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Room> _rooms = [];
  bool _isLoading = true;

  // Center coordinate (Default: Hue City)
  static const LatLng _defaultCenter = LatLng(16.4637, 107.5909);

  @override
  void initState() {
    super.initState();
    _fetchAndInitMarkers();
  }

  Future<void> _fetchAndInitMarkers() async {
    try {
      _rooms = await ApiService().getRooms();
      if (mounted) {
        setState(() {
          _markers.clear();
          for (int i = 0; i < _rooms.length; i++) {
            final room = _rooms[i];
            // If room doesn't have lat/lng, use mock coords spread around center
            final lat = room.location?.latitude ?? (_defaultCenter.latitude + (i * 0.002) - 0.005);
            final lng = room.location?.longitude ?? (_defaultCenter.longitude + (i * 0.002) - 0.005);
            
            _markers.add(
              Marker(
                markerId: MarkerId(room.id),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: room.title,
                  snippet: '${(room.price / 1000000).toStringAsFixed(1)} Tr/tháng',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
                    );
                  },
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              ),
            );
          }
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
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? _defaultCenter,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            style: Theme.of(context).brightness == Brightness.dark ? _darkMapStyle : null,
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Custom Search Bar on Top
          Positioned(
            top: 56,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 12),
                        Text('Tìm kiếm khu vực...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
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
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        _markers.firstWhere((m) => m.markerId.value == room.id).position,
                      ),
                    );
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
                          child: Image.network(
                            room.images.isNotEmpty ? room.images[0] : 'https://placehold.co/100',
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

  // Optional: Dark mode style for Google Maps (Simplified)
  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]}
  ]
  ''';
}
