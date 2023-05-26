import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//ログインしているユーザーのID.
String? userID = "";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  String infoText = "";

  void _loginAccount(String id, String pass) async {
    try {
      // credential にはアカウント情報が記録される
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id,
        password: pass,
      );
      // ログインに成功した場合
      final User user = credential.user!;
      userID = user.uid;
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed("/map");
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
          infoText = "ログインNG:${e.toString()}";
        });
      }
    } catch (e) {
      setState(() {
        infoText = "ログインNG:${e.toString()}";
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
            title: const Text('Log In Page',
                style: TextStyle(color: Colors.white))),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  ///初心者マーク
                  SizedBox(
                      height: 100,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipPath(
                                clipper: _LeftDiagonalClipper(),
                                child: Container(
                                  decoration: BoxDecoration(

                                      ///              border: Border.all(color: Colors.black.withOpacity(0.5), width: 4),
                                      ///              borderRadius: BorderRadius.circular(8),
                                      color: Colors.yellow.withOpacity(0.5)),
                                  width: 30,
                                )),
                            ClipPath(
                                clipper: _RightDiagonalClipper(),
                                child: Container(
                                  decoration: BoxDecoration(

                                      ///              border: Border.all(color: Colors.black.withOpacity(0.5), width: 4),
                                      ///              borderRadius: BorderRadius.circular(8),
                                      color: Colors.green.withOpacity(0.5)),
                                  width: 30,
                                ))
                          ])),

                  ///タイトル
                  const Text('App Title',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36,
                          fontWeight: FontWeight.bold))
                ]),
                SizedBox(
                    height: 400,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ///白線
                          Container(width: 20, color: Colors.white),

                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                /// メールアドレス入力
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                        label: Text('E-mail address',
                                            style: TextStyle(
                                                color: Colors.green))),
                                    controller: _idController,
                                    obscureText: false,
                                  ),
                                ),

                                ///パスワード入力
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                        label: Text('Password',
                                            style: TextStyle(
                                                color: Colors.green))),
                                    controller: _passController,
                                    obscureText: true,
                                  ),
                                ),

                                ///ログインボタン
                                SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _loginAccount(_idController.text,
                                          _passController.text);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow),
                                    child: const Text('Log In',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)),
                                  ),
                                ),

                                ///アカウント新規作成ボタン
                                SizedBox(
                                  width: 250,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pushNamed("/register");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow),
                                    child: const Text("Create New Account",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)),
                                  ),
                                ),

                                /// ゲストログイン
                                SizedBox(
                                  width: 250,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pushNamed("/map");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow),
                                    child: const Text("Guest Login",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)),
                                  ),
                                ),

                                /// エラー文などの表示
                                const SizedBox(height: 8),
                                Text(infoText),
                              ]),

                          ///白線
                          Container(width: 20, color: Colors.white)
                        ])),
              ]),
        ));
  }
}
