import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'Phòng trọ';
  final List<String> _roomTypes = ['Phòng trọ', 'Căn hộ mini', 'Nhà nguyên căn', 'Studio', 'Ở ghép'];
  
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final roomData = {
        'title': _titleController.text.trim(),
        'address': _addressController.text.trim(),
        'price': double.parse(_priceController.text.replaceAll('.', '').replaceAll(',', '')),
        'area': double.parse(_areaController.text),
        'description': _descriptionController.text.trim(),
        'category': _selectedType,
        'landlordId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Chờ duyệt',
        'images': [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80',
        ],
        'amenities': ['Wifi', 'Điều hòa', 'Chỗ để xe', 'Tự do', 'An ninh'],
        'rating': 0.0,
        'reviewCount': 0,
        'isFeatured': false,
        'location': const GeoPoint(16.4637, 107.5908),
      };

      await FirebaseFirestore.instance.collection('rooms').add(roomData);

      // Notify all admins about new pending room
      final adminSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      for (final adminDoc in adminSnap.docs) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': adminDoc.id,
          'title': 'Tin đăng mới chờ duyệt',
          'body': 'Chủ trọ vừa đăng tin "${_titleController.text.trim()}" cần được phê duyệt.',
          'type': 'room',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng tin thành công! Vui lòng chờ Admin duyệt.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error creating room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã có lỗi xảy ra khi đăng tin'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Đăng tin phòng mới', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin cơ bản'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Tiêu đề tin đăng',
                    hint: 'Ví dụ: Phòng trọ cao cấp trung tâm TP',
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Giá thuê (VNĐ/tháng)',
                          hint: '3.500.000',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Nhập giá' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _areaController,
                          label: 'Diện tích (m²)',
                          hint: '25',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Nhập diện tích' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Vị trí & Hình ảnh'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Địa chỉ chi tiết',
                    hint: 'Số 123 đường Lê Lợi, TP Huế',
                    icon: Icons.location_on_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildImagePlaceholder(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Mô tả chi tiết'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Mô tả',
                    hint: 'Thông tin thêm về phòng, giờ giấc, điện nước...',
                    maxLines: 5,
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mô tả' : null,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Đăng tin ngay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6E797A)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loại hình', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => _selectedType = newValue);
              },
              items: _roomTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hình ảnh phòng (Tối đa 5 ảnh)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryColor.withValues(alpha: 0.5), size: 32),
              const SizedBox(height: 8),
              const Text('Nhấn để chọn ảnh', style: TextStyle(color: Color(0xFF6E797A), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
