import 'package:emotion_chat/service/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:emotion_chat/widgets/user_tile.dart';
import '../service/auth/auth_service.dart';
import '../widgets/home_drawer.dart';
import 'package:emotion_chat/screens/chat_page.dart';

// HomePage -> UserList
class UserList extends StatelessWidget {
  UserList({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User List")),
      // drawer: const HomeDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users
  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUserStream(),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return const Text("Error");
          }

          //loading ..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading..");
          }
          //return list view
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          );
        });
  }

  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    //display all users except current user
    return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
            ),
          ),
        );
      },
    );
  }
}
