class Room {
  final String id;
  final String title;
  final String description;
  final double price;
  final double area;
  final String address;
  final List<String> imageUrls;
  final List<String> amenities;
  final String type; // Entire house, mini apartment, shared room
  final double rating;
  final int reviewCount;
  final String landlordId;
  final bool isFeatured;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.area,
    required this.address,
    required this.imageUrls,
    required this.amenities,
    required this.type,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.landlordId,
    this.isFeatured = false,
  });

  factory Room.mock() {
    return Room(
      id: '1',
      title: 'Phòng trọ cao cấp gần Đại học Khoa học Huế',
      description: 'Phòng đầy đủ tiện nghi, nội thất cao cấp, gần trường Đại học Khoa học.',
      price: 2500000,
      area: 25.5,
      address: '77 Nguyễn Huệ, TP. Huế',
      imageUrls: [
        'https://images.unsplash.com/photo-1522771739844-649f43921f8b',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
      ],
      amenities: ['Wifi', 'AC', 'Parking', 'Fridge', 'Washing Machine'],
      type: 'Mini Apartment',
      rating: 4.8,
      reviewCount: 24,
      landlordId: 'landlord_1',
      isFeatured: true,
    );
  }

  static List<Room> getHueMockRooms() {
    return [
      Room.mock(),
      Room(
        id: '2',
        title: 'Căn hộ Studio thoáng mát Trường Chinh',
        description: 'Căn hộ yên tĩnh, có ban công, an ninh 24/7.',
        price: 3200000,
        area: 30.0,
        address: '12 Trường Chinh, TP. Huế',
        imageUrls: ['https://images.unsplash.com/photo-1493809842364-78817add7ffb'],
        amenities: ['Wifi', 'Parking', 'Fridge'],
        type: 'Studio',
        rating: 4.5,
        reviewCount: 12,
        landlordId: 'landlord_2',
      ),
      Room(
        id: '3',
        title: 'Phòng trọ giá rẻ Kim Long',
        description: 'Phòng sạch sẽ, gần sông Hương, không khí trong lành.',
        price: 1500000,
        area: 20.0,
        address: 'Kim Long, TP. Huế',
        imageUrls: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'],
        amenities: ['Wifi', 'Parking'],
        type: 'Shared Room',
        rating: 4.2,
        reviewCount: 8,
        landlordId: 'landlord_3',
      ),
    ];
  }
}
