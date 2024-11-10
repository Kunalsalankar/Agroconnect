import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String buyerId;
  final String sellerId;

  ChatPage({required this.buyerId, required this.sellerId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = _getChatRoomId(widget.buyerId, widget.sellerId);
  }

  String _getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
        'senderId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.sellerId}'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isCurrentUser = messageData['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(messageData['message'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
