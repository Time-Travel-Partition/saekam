import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emotion_chat/screens/main/chat_tab/chat_list_screen.dart';
import 'package:emotion_chat/services/chat/chat_service.dart';
import 'package:emotion_chat/services/openai/openai_service.dart';
import 'package:emotion_chat/widgets/list_item/chat_bubble.dart';
import 'package:emotion_chat/widgets/textfield/auth_textfield.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final int emotion;

  ChatScreen({
    super.key,
    required this.emotion,
  });

  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();

  final openAIService = OpenAIService();

  getEmotionString(int index) {
    if (index == 0) return '기쁨';
    if (index == 1) return '화남';
    if (index == 2) return '불안';
    if (index == 3) return '우울';
  }

  Future<List<String>> getConversationHistory() async {
    List<String> contentsList = [];
    var messagesStream = _chatService.getMessages(emotion);

    try {
      // 스트림에서 메시지 내용을 가져와 배열에 저장
      await for (var snapshot in messagesStream) {
        for (var message in snapshot.docs) {
          var data = message.data() as Map<String, dynamic>;
          if (data['isBot'] == false) {
            contentsList.add(data['content']);
          }
        }
      }
    } catch (e) {
      // 에러 처리
      print('스트림 처리 중 에러 발생: $e');
    }
    return contentsList;
  }

  //send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessage(emotion, _messageController.text, false);
      receiveMessage();
      // clear text controller
      _messageController.clear();
    }
  }

  void receiveMessage() async {
    //final conversationHistory = await getConversationHistory();

    final message = await openAIService.createModel(
        _messageController.text, getEmotionString(emotion));
    await _chatService.sendMessage(emotion, message, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getEmotionString(emotion),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.background,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(child: _buildMessageList()),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(emotion),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text('errors');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        }
        // 메시지 전송시 자동으로 스크롤 최하단으로 내리는 것 필요
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message Item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // 현재 로그인한 유저와 동일여부 파악
    bool isCurrentUser = !data['isBot'];

    // 현재 로그인한 유저의 메시지는 오른쪽으로 정렬 아니면 왼쪽정렬
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          ChatBubble(
            message: data['content'],
            emotion: emotion,
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 40.0),
      child: Row(
        children: [
          //텍스트 필드가 대부분의 공간을 차지하도록 설정
          Expanded(
            child: AuthTextField(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
            ),
          ),

          //send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
