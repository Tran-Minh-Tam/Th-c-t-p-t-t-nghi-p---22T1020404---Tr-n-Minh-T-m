import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'create_room_screen.dart';

class EditRoomScreen extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;
  const EditRoomScreen({super.key, required this.roomId, required this.roomData});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  bool _isLoading = false;

  final List<String> _roomTypes = ['Phòng trọ', 'Căn hộ mini', 'Nhà nguyên căn', 'Studio', 'Ở ghép', 'Căn hộ'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.roomData['title'] ?? '');
    _addressController = TextEditingController(text: widget.roomData['address'] ?? '');
    
    // Format initial price
    String initialPrice = (widget.roomData['price'] ?? 0).toString();
    if (initialPrice != '0' && initialPrice.isNotEmpty) {
      initialPrice = NumberFormat('#,###', 'vi_VN').format((double.tryParse(initialPrice) ?? 0).toInt()).replaceAll(',', '.');
    }
    _priceController = TextEditingController(text: initialPrice);
    
    _areaController = TextEditingController(text: (widget.roomData['area'] ?? 0).toString());
    _descriptionController = TextEditingController(text: widget.roomData['description'] ?? '');
    _selectedType = _roomTypes.contains(widget.roomData['category'] ?? widget.roomData['type'])
        ? (widget.roomData['category'] ?? widget.roomData['type'])
        : _roomTypes[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
        'title': _titleController.text.trim(),
        'address': _addressController.text.trim(),
        'price': double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0,
        'area': double.tryParse(_areaController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'category': _selectedType,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật tin đăng!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật'), backgroundColor: Colors.red),
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
        title: const Text('Chỉnh sửa tin đăng', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryContainer), onPressed: () => Navigator.pop(context)),
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
                    _buildField(_titleController, 'Tiêu đề', 'Tên phòng trọ', validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
                    const SizedBox(height: 20),
                    const Text('Loại hình', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          onChanged: (v) { if (v != null) setState(() => _selectedType = v); },
                          items: _roomTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: _buildField(_priceController, 'Giá (VNĐ/tháng)', '3500000', keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()], validator: (v) => v!.isEmpty ? 'Bắt buộc' : null)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField(_areaController, 'Diện tích (m²)', '25', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Bắt buộc' : null)),
                    ]),
                    const SizedBox(height: 20),
                    _buildField(_addressController, 'Địa chỉ', 'Số nhà, đường...', validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
                    const SizedBox(height: 20),
                    _buildField(_descriptionController, 'Mô tả', 'Thông tin về phòng...', maxLines: 5, validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines, keyboardType: keyboardType, validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
