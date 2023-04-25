import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

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
      setState(() {
        //infoText = "ログインOK：${user.email}";
        Navigator.of(context).pushNamed("/map");
      });
    }

    /// ログインに失敗した場合のエラー処理
    on FirebaseAuthException catch (e) {
      /// ログインに失敗した場合
      setState(() {
        infoText = "ログインNG：${e.toString()}";
      });
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
            child: Text("新規登録はこちら"),
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
