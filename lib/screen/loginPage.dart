import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

String? userID = "";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _idController = TextEditingController();
  var _passController = TextEditingController();
  String infoText = "";

  void _loginAccount(String id, String pass) async {
    try {
      /// credential にはアカウント情報が記録される
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id,
        password: pass,
      );
      // ログインに成功した場合
      final User user = credential.user!;
      userID = user.uid;
      Navigator.of(context).pushNamed("/home");
    }

    /// ログインに失敗した場合のエラー処理
    on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        setState(() {
          infoText = "メールアドレスが間違っています。";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          infoText = "パスワードが間違っています。";
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          infoText = "このアカウントは存在しません。";
        });
      } else if (e.code == 'user-disabled') {
        setState(() {
          infoText = "このメールアドレスは無効になっています。";
        });
      } else if (e.code == 'too-many-requests') {
        setState(() {
          infoText = "回線が混雑しています。もう一度試してみてください。";
        });
      } else if (e.code == 'operation-not-allowed') {
        setState(() {
          infoText = "メールアドレスとパスワードでのログインは有効になっていません。";
        });
      } else if (e.code == 'EmailAlreadyExists') {
        setState(() {
          infoText = "このメールアドレスはすでに登録されています。";
        });
      } else if (e.code == 'Undefined') {
        setState(() {
          infoText = "予期せぬエラーが発生しました。";
        });
      } else {
        setState(() {
          infoText = "ログインNG：${e.toString()}";
        });
      }
    } catch (e) {
      setState(() {
        infoText = "ログインNG：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログインページ'),
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
            onPressed: () async {
              _loginAccount(_idController.text, _passController.text);
            },
            child: const Text('ログイン'),
          ),
        ),
        Center(
          child: ElevatedButton(
            child: const Text("新規登録はこちら"),
            onPressed: () async {
              Navigator.of(context).pushNamed("/register");
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(infoText),
      ]),
    );
  }
}
