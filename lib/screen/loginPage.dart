import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _idController = TextEditingController();
  var _passController = TextEditingController();

  void _createAccount(String id, String pass) async {
    try {
      /// credential にはアカウント情報が記録される
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: id,
        password: pass,
      );
    }

    /// アカウントに失敗した場合のエラー処理
    on FirebaseAuthException catch (e) {
      /// パスワードが弱い場合
      if (e.code == 'weak-password') {
        print('パスワードが弱いです');

        /// メールアドレスが既に使用中の場合
      } else if (e.code == 'email-already-in-use') {
        print('すでに使用されているメールアドレスです');
      }

      /// その他エラー
      else {
        print('アカウント作成エラー');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('ログインページ'),
      ),
      body: Column(children: [
        Center(
          child: ElevatedButton(
            child: Text("新規登録はこちら"),
            onPressed: () async {
              Navigator.of(context).pushNamed("/register");
            },
          ),
        ),
      ]),
    );
  }
}
