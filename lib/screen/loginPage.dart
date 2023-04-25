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
