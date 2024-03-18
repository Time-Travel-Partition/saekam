import 'dart:io';

import 'package:emotion_chat/screens/main/profile_tab/settings_screen.dart';
import 'package:emotion_chat/services/auth/auth_gate.dart';
import 'package:emotion_chat/services/auth/auth_service.dart';
import 'package:emotion_chat/services/image/local_storage/profile_image_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  File? image; // Nullable
  late String email;
  late String name;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    email = _auth.currentUser!.email!;
    name = _auth.currentUser!.displayName ?? '';

    // 로컬에 저장된 프로필 이미지 불러와 state에 저장
    _profileImageService.loadImage(email).then((loadedImage) {
      if (loadedImage != null) {
        setState(() {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
          image = loadedImage;
        });
      }
    });
  }

  void signOut() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
        (route) => false);
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            // 프로필 이미지
            currentAccountPicture: (image != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image(
                      image: FileImage(
                        File(image!.path),
                      ),
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.blue),
                    ),
                  ),
            accountName: Text(name),
            accountEmail: Text(email),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              title: const Text('다크모드'),
              leading: const Icon(
                Icons.dark_mode_rounded,
                color: Colors.blue,
              ),
              onTap: () {
                //pop the drawer
                Navigator.pop(context);
              },
            ),
          ),

          // settings tile
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              title: const Text('환경설정'),
              leading: const Icon(
                Icons.settings,
                color: Colors.blue,
              ),
              onTap: () {
                //pop the drawer
                Navigator.pop(context);

                //Navigate to settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),

          // logout tile
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              title: const Text('로그아웃'),
              leading: const Icon(
                Icons.logout,
                color: Colors.blue,
              ),
              onTap: signOut,
            ),
          ),
        ],
      ),
    );
  }
}
