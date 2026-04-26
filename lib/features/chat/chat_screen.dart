import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

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

  String get _chatId {
    if (_currentUser!.uid.hashCode <= widget.peerId.hashCode) {
      return '${_currentUser!.uid}_${widget.peerId}';
    } else {
      return '${widget.peerId}_${_currentUser!.uid}';
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    final senderName = _currentUser?.displayName ?? 'Người dùng';

    // Get sender name from Firestore for better display
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
      'content': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    // Update conversation metadata
    await FirebaseFirestore.instance.collection('conversations').doc(_chatId).set({
      'lastMessage': message,
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
      'body': message.length > 60 ? '${message.substring(0, 60)}...' : message,
      'type': 'message',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const NetworkImage('https://placehold.co/100'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
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
        IconButton(icon: const Icon(Icons.phone, color: AppTheme.primaryColor), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.primaryColor), onPressed: () {}),
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
            return _buildTextMessage(data['content'], isMe, _formatTimestamp(data['timestamp']));
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
                  child: Image.network(imageUrl, fit: BoxFit.cover, height: 150, width: double.infinity),
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
          const Icon(Icons.add_circle, color: Colors.grey, size: 28),
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
                  const Icon(Icons.image, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
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
}
