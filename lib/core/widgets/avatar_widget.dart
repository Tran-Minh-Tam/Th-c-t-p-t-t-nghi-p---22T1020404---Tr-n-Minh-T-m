import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool showStatus;
  final bool isOnline;
  final String? avatarType; // 'bear', 'cat', or null for default

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.showStatus = false,
    this.isOnline = false,
    this.avatarType,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: Colors.grey[200],
      );
    } else {
      // Use cute dicebear avatar based on name or type
      String seed = name ?? avatarType ?? 'default';
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$seed&backgroundColor=b6e3f4'),
        backgroundColor: Colors.grey[200],
      );
    }

    if (!showStatus) {
      return avatar;
    }

    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: radius * 0.4,
            height: radius * 0.4,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.primaryColor : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor() {
    switch (avatarType) {
      case 'bear':
        return const Color(0xFF8B4513); // Brown
      case 'cat':
        return const Color(0xFF708090); // Slate gray
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _getAvatarIcon() {
    switch (avatarType) {
      case 'bear':
        return Icon(
          Icons.pets,
          color: Colors.white,
          size: radius * 1.2,
        );
      case 'cat':
        return Icon(
          Icons.cruelty_free,
          color: Colors.white,
          size: radius * 1.2,
        );
      default:
        return Icon(
          Icons.person,
          color: Colors.white,
          size: radius * 1.2,
        );
    }
  }
}

class AvatarPicker extends StatefulWidget {
  final String? currentAvatarType;
  final Function(String) onAvatarSelected;

  const AvatarPicker({
    super.key,
    this.currentAvatarType,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  String? _selectedAvatarType;

  @override
  void initState() {
    super.initState();
    _selectedAvatarType = widget.currentAvatarType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Chọn ảnh đại diện',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatarOption('default', Icons.person, 'Mặc định'),
              _buildAvatarOption('bear', Icons.pets, 'Gấu'),
              _buildAvatarOption('cat', Icons.cruelty_free, 'Mèo'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectedAvatarType != null
                    ? () {
                        widget.onAvatarSelected(_selectedAvatarType!);
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Chọn'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarOption(String type, IconData icon, String label) {
    final isSelected = _selectedAvatarType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarType = type;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: AvatarWidget(
              avatarType: type == 'default' ? null : type,
              radius: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
