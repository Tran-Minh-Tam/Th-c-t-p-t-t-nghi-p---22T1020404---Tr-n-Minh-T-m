import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Room {
  final String id;
  final String title;
  final String description;
  final double price;
  final String address;
  final double area;
  final List<String> images;
  final String category;
  final double rating;
  final String landlordId;
  final LatLng? location;
  final String status;
  final bool isFeatured;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.area,
    required this.images,
    required this.category,
    required this.rating,
    required this.landlordId,
    this.location,
    this.status = 'approved',
    this.isFeatured = false,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    LatLng? loc;
    if (data['location'] != null && data['location'] is GeoPoint) {
      GeoPoint geoPoint = data['location'];
      loc = LatLng(geoPoint.latitude, geoPoint.longitude);
    }

    return Room(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      area: (data['area'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? (data['imageUrls'] ?? [])),
      category: data['category'] ?? (data['type'] ?? 'Phòng trọ'),
      rating: (data['rating'] ?? 0).toDouble(),
      landlordId: data['landlordId'] ?? '',
      location: loc,
      status: data['status'] ?? 'approved',
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  factory Room.fromJson(Map<String, dynamic> data) {
    return Room(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      area: (data['area'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? (data['imageUrls'] ?? [])),
      category: data['category'] ?? (data['type'] ?? 'Phòng trọ'),
      rating: (data['rating'] ?? 0).toDouble(),
      landlordId: data['landlordId'] ?? '',
      status: data['status'] ?? 'approved',
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  static List<Room> getHueMockRooms() {
    return [
      Room(
        id: '1',
        title: 'Căn hộ Studio cao cấp view Sông Hương',
        description: 'Phòng đầy đủ tiện nghi, ban công rộng, an ninh 24/7.',
        price: 4500000,
        address: 'Lê Lợi, TP. Huế',
        area: 35,
        images: ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1000'],
        category: 'Căn hộ',
        rating: 4.8,
        landlordId: 'landlord_1',
        location: const LatLng(16.4637, 107.5909),
        isFeatured: true,
      ),
      Room(
        id: '2',
        title: 'Phòng trọ sinh viên gần ĐH Sư Phạm',
        description: 'Giá rẻ, yên tĩnh, gần chợ và trường học.',
        price: 1800000,
        address: 'Lê Huân, TP. Huế',
        area: 20,
        images: ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000'],
        category: 'Phòng trọ',
        rating: 4.5,
        landlordId: 'landlord_2',
        location: const LatLng(16.4745, 107.5786),
      ),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'area': area,
      'images': images,
      'category': category,
      'rating': rating,
      'landlordId': landlordId,
      'location': location != null ? GeoPoint(location!.latitude, location!.longitude) : null,
      'status': status,
      'isFeatured': isFeatured,
    };
  }
}
