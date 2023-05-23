import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

///初心者マークの描画
class _LeftDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width * 1.0, size.height * 0.3)
      ..lineTo(size.width * 1.0, size.height * 1.0)
      ..lineTo(0, size.height * 0.7)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper oldclipper) {
    return true;
  }
}

class _RightDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height * 0.3)
      ..lineTo(size.width * 1.0, 0)
      ..lineTo(size.width * 1.0, size.height * 0.7)
      ..lineTo(0, size.height * 1.0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper oldclipper) {
    return true;
  }
}

class _RegisterPage extends State<RegisterPage> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool skill = false;
  String infoText = "アカウント作成後、自動でログインページに移動します";

  void _createAccount(String id, String pass, bool skill) async {
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
          .set({'email': id, 'password': pass, 'skillIsExpert': skill}); // データ
      Navigator.of(context).pushNamed("/login");
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
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 215, 213, 213),
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Sign Up'),
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  ///初心者マーク
                  Container(
                      height: 100,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipPath(
                                clipper: _LeftDiagonalClipper(),
                                child: Container(
                                    decoration: BoxDecoration(

                                        ///              border: Border.all(color: Colors.black, width: 4),
                                        ///              borderRadius: BorderRadius.circular(8),
                                        color: Colors.yellow.withOpacity(0.5)),
                                    width: 30)),
                            ClipPath(
                                clipper: _RightDiagonalClipper(),
                                child: Container(
                                    decoration: BoxDecoration(

                                        ///              border: Border.all(color: Colors.black, width: 4),
                                        ///              borderRadius: BorderRadius.circular(8),
                                        color: Colors.green.withOpacity(0.5)),
                                    width: 30))
                          ])),

                  ///タイトル
                  Text('App Title',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36,
                          fontWeight: FontWeight.bold))
                ]),
                Container(
                    height: 400,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ///白線
                          Container(width: 20, color: Colors.white),

                          Container(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                /// メールアドレス入力
                                Container(
                                  width: 250,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        label: Text('E-mail Address',
                                            style: TextStyle(
                                                color: Colors.green))),
                                    controller: _idController,
                                    obscureText: false,
                                  ),
                                ),

                                /// パスワード入力
                                Container(
                                  width: 250,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        label: Text('Password',
                                            style: TextStyle(
                                                color: Colors.green))),
                                    controller: _passController,
                                    obscureText: true,
                                  ),
                                ),
                                const Text('駐車スキル'),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  //padding: const EdgeInsets.only(left: 80),
                                  width: 200,
                                  color: Colors.white,
                                  child: DropdownButton(
                                    hint: Text('駐車スキル'),
                                    items: const [
                                      DropdownMenuItem(
                                        child: Text('初心者'),
                                        value: false,
                                      ),
                                      DropdownMenuItem(
                                        child: Text('初心者ではない'),
                                        value: true,
                                      ),
                                    ],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        skill = value!;
                                      });
                                    },
                                    value: skill,
                                  ),
                                ),

                                ///アカウント作成ボタン
                                Container(
                                  width: 150,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _createAccount(_idController.text,
                                          _passController.text, skill);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow),
                                    child: const Text('Sign Up',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)),
                                  ),
                                ),
                              ])),

                          ///白線
                          Container(width: 20, color: Colors.white),
                        ])),
                // エラー文などの表示
                const SizedBox(height: 8),
                Text(infoText),
              ]),
        ));
  }
}
