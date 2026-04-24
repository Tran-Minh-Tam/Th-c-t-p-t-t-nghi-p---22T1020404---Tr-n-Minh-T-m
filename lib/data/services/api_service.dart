import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';

class ApiService {
  // Thay thế URL này bằng API endpoint thực tế của bạn
  static const String baseUrl = 'https://api.example.com/api/v1';

  Future<List<Room>> getRooms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Room.fromJson(json)).toList();
      } else {
        // Trong trường hợp lỗi API (vd: URL giả), chúng ta trả về dữ liệu mock để UI không bị trống
        return Room.getHueMockRooms();
      }
    } catch (e) {
      // Bắt lỗi network và trả về dữ liệu mock tạm thời
      return Room.getHueMockRooms();
    }
  }

  Future<Room> getRoomById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms/$id'));

      if (response.statusCode == 200) {
        return Room.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load room');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
