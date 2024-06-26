import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emotion_chat/screens/main/chat_tab/chat_list_screen.dart';
import 'package:emotion_chat/services/chat/chat_service.dart';
import 'package:emotion_chat/services/openai/openai_service.dart';
import 'package:emotion_chat/widgets/list_item/chat_bubble.dart';
import 'package:emotion_chat/widgets/modal/confirm_or_cancel_alert.dart';
import 'package:emotion_chat/widgets/textfield/auth_textfield.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final int emotion;

  const ChatScreen({
    super.key,
    required this.emotion,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final openAIService = OpenAIService();
  //채팅 입력 시 키보드를 띄우고, 자동으로 채팅내역을 스크롤
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print(openAIService.messagesList);

    // 포커스 노드 리스너 생성
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessage(
          widget.emotion, _messageController.text, false);
      receiveMessage();
      // clear text controller
      _messageController.clear();
    }

    scrollDown();
  }

  void receiveMessage() async {
    //final conversationHistory = await getConversationHistory();

    final message = await openAIService.createModel(
        _messageController.text, widget.emotion);
    await _chatService.sendMessage(widget.emotion, message, true);
    scrollDown();
  }

  void onFinishConsultation() {
    // 채팅 내역 백업
    _chatService.backupChatHistory(widget.emotion);

    // 해당 채팅방 제거
    _chatService.deleteChatRoom(widget.emotion);

    // ChatListScreen으로 돌아가기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListScreen(),
      ),
    );
  }

  getEmotionString(int index) {
    if (index == 0) return '기쁨';
    if (index == 1) return '화남';
    if (index == 2) return '불안';
    if (index == 3) return '우울';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: Text(
            getEmotionString(widget.emotion),
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
          actions: [
            TextButton(
              onPressed: () {
                //상담종료 버튼 누르는 경우
                showDialog(
                  context: context,
                  builder: (context) => ConfirmOrCancelAlert(
                    message: '상담을 종료하시겠습니까?',
                    onPressedConfirm: onFinishConsultation,
                  ),
                );
              },
              child: const Text(
                '종료',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
      stream: _chatService.getMessages(widget.emotion),
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
          controller: _scrollController,
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
            emotion: widget.emotion,
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
              focusNode: myFocusNode,
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
