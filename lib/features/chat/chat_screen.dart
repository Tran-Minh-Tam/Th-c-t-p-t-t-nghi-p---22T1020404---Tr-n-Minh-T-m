import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_widget.dart';
import 'package:intl/intl.dart';
import '../../widgets/safe_network_image.dart';
import 'package:geolocator/geolocator.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? roomTitle;

  const ChatScreen({
    super.key, 
    required this.peerId, 
    required this.peerName,
    this.roomTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _chatId {
    if (_currentUser!.uid.hashCode <= widget.peerId.hashCode) {
      return '${_currentUser!.uid}_${widget.peerId}';
    } else {
      return '${widget.peerId}_${_currentUser!.uid}';
    }
  }

  void _sendMessage({String? type, String? content, Map<String, dynamic>? metadata}) async {
    final messageContent = content ?? _messageController.text.trim();
    if (messageContent.isEmpty && type == null) return;
    
    if (content == null) _messageController.clear();

    final senderName = _currentUser?.displayName ?? 'Người dùng';
    String senderDisplayName = senderName;
    try {
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      senderDisplayName = senderDoc.data()?['fullName'] ?? senderName;
    } catch (_) {}

    final messageData = {
      'senderId': _currentUser!.uid,
      'receiverId': widget.peerId,
      'content': messageContent,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type ?? 'text',
      if (metadata != null) 'metadata': metadata,
    };

    // Update conversation metadata
    await FirebaseFirestore.instance.collection('conversations').doc(_chatId).set({
      'lastMessage': type == 'image' ? '[Hình ảnh]' : (type == 'location' ? '[Vị trí]' : messageContent),
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participantIds': [_currentUser!.uid, widget.peerId],
      'participantNames': {
        _currentUser!.uid: senderDisplayName,
        widget.peerId: widget.peerName,
      },
    }, SetOptions(merge: true));

    // Add message to subcollection
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_chatId)
        .collection('messages')
        .add(messageData);

    // Send notification to receiver
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': widget.peerId,
      'title': 'Tin nhắn mới từ $senderDisplayName',
      'body': type == 'image' ? 'Đã gửi một hình ảnh' : (type == 'location' ? 'Đã chia sẻ vị trí' : messageContent),
      'type': 'message',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isMock = widget.peerId == 'mock';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: isMock 
                ? _buildMockChat() 
                : _buildFirebaseChat(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          AvatarWidget(
            imageUrl: null,
            name: widget.peerName,
            radius: 20,
            showStatus: true,
            isOnline: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName.toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('TRỰC TUYẾN', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: AppTheme.primaryColor), 
          onPressed: () => _showCallDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.primaryColor), 
          onPressed: () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildFirebaseChat() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final messages = snapshot.data!.docs;
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            final isMe = data['senderId'] == _currentUser!.uid;
            final type = data['type'] ?? 'text';
            final time = _formatTimestamp(data['timestamp']);

            if (type == 'image') {
              return _buildImageMessage(data['content'], '', isMe, time);
            } else if (type == 'location') {
              return _buildLocationMessage(data['content'], isMe, time);
            }
            return _buildTextMessage(data['content'], isMe, time);
          },
        );
      },
    );
  }

  Widget _buildMockChat() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: const Text('HÔM NAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextMessage('Xin chào! Tôi vừa xác nhận yêu cầu bảo trì vòi nước nhà bếp. Thợ sửa ống nước sẽ đến vào 10 giờ sáng mai. Thời gian đó có tiện cho bạn không?', false, '09:12 SA'),
        _buildTextMessage('Thời gian đó hoàn toàn phù hợp. Tôi sẽ ở nhà để mở cửa cho họ. Cảm ơn vì đã phản hồi nhanh chóng, Julian!', true, '09:15 SA'),
        const SizedBox(height: 16),
        _buildActiveLeaseCard(),
        const SizedBox(height: 16),
        _buildImageMessage('https://placehold.co/400x250', 'Tuyệt vời. Đây là bộ phận tôi đã đặt. Chỉ muốn đảm bảo nó khớp với thiết bị hiện tại của bạn.', false, '09:45 SA'),
        const SizedBox(height: 16),
        _buildVoiceMessage(true, '09:50 SA'),
      ],
    );
  }

  Widget _buildTextMessage(String content, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(
              content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              if (isMe) const SizedBox(width: 4),
              if (isMe) const Icon(Icons.done_all, size: 14, color: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActiveLeaseCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.home_work, color: Color(0xFFFFD700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HỢP ĐỒNG ĐANG HOẠT ĐỘNG', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('The Penthouse Sanctuary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text('Phòng 402 • Hết hạn Tháng 10 2024', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl, String content, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SafeNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, height: 180, width: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                )
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(String locationName, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor.withOpacity(0.9) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: isMe ? Colors.white : AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text('Vị trí đã chia sẻ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(locationName, style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SafeNetworkImage(
                    imageUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=16.4637,107.5909&zoom=15&size=400x200&key=AIzaSyCVBFquZG_eRkq0xQmh_g80e1KPONj4Omw',
                    height: 100, width: double.infinity, fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isMe ? 24 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.white54,
                    child: Row(
                      children: [
                        Container(width: 40, height: 2, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('0:12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              if (isMe) const SizedBox(width: 4),
              if (isMe) const Icon(Icons.done_all, size: 14, color: AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 12),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.grey, size: 28),
            onPressed: () => _showAttachmentOptions(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.grey, size: 20),
                    onPressed: () => _pickImage(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping ? () => _sendMessage() : _startVoiceRecording,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isTyping ? AppTheme.primaryColor : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return DateFormat('HH:mm').format(date);
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gọi cho ${widget.peerName}'),
        content: const Text('Chức năng gọi điện đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Xem thông tin'),
              onTap: () {
                Navigator.pop(context);
                _showUserInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Tắt thông báo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã tắt thông báo cho cuộc trò chuyện này')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa cuộc trò chuyện', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'image', content: 'https://api.dicebear.com/7.x/shapes/png?seed=Felix&backgroundColor=b6e3f4');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'image', content: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Felix&backgroundColor=b6e3f4');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Gửi vị trí'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }
                  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                    Position position = await Geolocator.getCurrentPosition();
                    _sendMessage(type: 'location', content: 'Tọa độ: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
                  } else {
                    _sendMessage(type: 'location', content: 'Đại nội Huế, Thừa Thiên Huế');
                  }
                } catch (e) {
                  _sendMessage(type: 'location', content: 'Đại nội Huế, Thừa Thiên Huế');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chọn ảnh đang được phát triển')),
    );
  }

  void _startVoiceRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng ghi âm đang được phát triển')),
    );
  }

  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin: ${widget.peerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trạng thái: Trực tuyến'),
            const SizedBox(height: 8),
            Text('ID: ${widget.peerId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cuộc trò chuyện'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ cuộc trò chuyện này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa đang được phát triển')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
