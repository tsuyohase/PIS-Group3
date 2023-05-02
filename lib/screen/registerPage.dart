import 'package:cloud_firestore/cloud_firestore.dart';
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
  String infoText = "アカウント作成に成功すると自動でログインページに移動します。";

  void _createAccount(String id, String pass) async {
    try {
      /// credential にはアカウント情報が記録される
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: id,
        password: pass,
      );
      final User user = credential.user!;
      await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(user.uid) // ドキュメントID
          .set({'email': id, 'password': pass, 'skill': "None"}); // データ
      Navigator.of(context).pushNamed("/login");
      // setState(() {
      //   infoText = "登録完了：${user.email}";
      // });
    }

    /// アカウントに失敗した場合のエラー処理
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          infoText = "すでに使用されているメールアドレスです";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          infoText = "パスワードが弱いです";
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
          infoText = "アカウント作成エラー：${e.toString()}";
        });
      }
    } catch (e) {
      setState(() {
        infoText = "アカウント作成エラー：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録ページ'),
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
