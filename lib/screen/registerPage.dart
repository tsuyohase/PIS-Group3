import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  var _idController = TextEditingController();
  var _passController = TextEditingController();
  String infoText = "";

  void _createAccount(String id, String pass) async {
    try {
      /// credential にはアカウント情報が記録される
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: id,
        password: pass,
      );
      final User user = credential.user!;
      setState(() {
        infoText = "登録完了：${user.email}";
      });
    }

    /// アカウントに失敗した場合のエラー処理
    on FirebaseAuthException catch (e) {
      /// パスワードが弱い場合
      if (e.code == 'weak-password') {
        setState(() {
          infoText = "パスワードが弱いです";
        });

        /// メールアドレスが既に使用中の場合
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          infoText = "すでに使用されているメールアドレスです";
        });

        /// その他エラー
      } else {
        setState(() {
          infoText = "アカウント作成エラー";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('新規登録ページ'),
      ),
      body: Column(children: [
        /// メールアドレス入力
        TextField(
          decoration: const InputDecoration(
            label: Text('E-mail'),
          ),
          controller: _idController,
        ),

        /// パスワード入力
        TextField(
          decoration: const InputDecoration(
            label: Text('Password'),
          ),
          controller: _passController,
          obscureText: true,
        ),
        Container(
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              _createAccount(_idController.text, _passController.text);
            },
            child: const Text('アカウント作成'),
          ),
        ),
        const SizedBox(height: 8),
        Text(infoText),
      ]),
    );
  }
}
