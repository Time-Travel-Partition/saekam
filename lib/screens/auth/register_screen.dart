import 'package:flutter/material.dart';
import 'package:emotion_chat/widgets/button/auth_button.dart';
import 'package:emotion_chat/services/auth/auth_service.dart';
import 'package:emotion_chat/widgets/textfield/auth_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emotion_chat/widgets/modal/confirm_alert.dart';

import '../../utils/regex.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;

  // email and pw text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  void register(BuildContext context) async {
    final auth = AuthService();

    // 비밀번호와 비밀번호 확인이 서로 같은지 판단
    String? notSamePwMessage =
        validatePasswordConfirm(_pwController.text, _confirmPwController.text);
    if (notSamePwMessage == null) {
      // 비밀번호가 유효한 형식인지 판단(특수문자 포함 여부 등)
      String? invalidPwMessage = validatePassword(_pwController.text);
      if (invalidPwMessage == null) {
        try {
          setState(() {
            isLoading = true;
          });

          await auth.signUpWithEmailPassword(
            _emailController.text,
            _pwController.text,
          );

          setState(() {
            isLoading = false;
          });
        } on FirebaseAuthException catch (e) {
          setState(() {
            isLoading = false;
          });
          // 로그인 실패 시 AlertDialog 띄우기
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmAlert(message: e.message ?? '로그인 실패');
              },
            );
          }
        }
      } else {
        // 비밀번호가 유효하지 않은 형식이면
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmAlert(message: invalidPwMessage);
          },
        );
      }
    } else {
      // 비밀번호가 서로 일치하지 않으면
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmAlert(message: notSamePwMessage);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.message,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 50,
                ),

                // welcom back message
                Text(
                  '이메일과 비밀번호를 입력해주세요',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

                // email textfield
                AuthTextField(
                  hintText: '이메일',
                  obscureText: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 10),

                // pw textfield
                AuthTextField(
                  hintText: '비밀번호',
                  obscureText: true,
                  controller: _pwController,
                ),
                const SizedBox(height: 10),

                // confirm pw textfield
                AuthTextField(
                  hintText: '비밀번호 확인',
                  obscureText: true,
                  controller: _confirmPwController,
                ),
                const SizedBox(height: 25),

                // register button
                AuthButton(
                  text: '회원가입',
                  onTap: () => register(context),
                ),
                const SizedBox(height: 25),

                // register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '이미 계정이 있으신가요? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        '로그인하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
    );
  }
}
