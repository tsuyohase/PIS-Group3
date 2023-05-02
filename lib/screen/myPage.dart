import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'loginPage.dart';

String userInfoText = "";
String infoText = "";

Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
  final userInfo =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  return userInfo;
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  var _skillController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('マイページ'),
        ),
        body: Column(children: [
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                userInfoText = 'ログイン中のアカウント：' + snapshot.data!['email'];
              } else {
                userInfoText = "ログインしていません";
              }
              return Text(userInfoText);
            },
          ),
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                userInfoText = '駐車スキル：' + snapshot.data!['skill'];
              } else {
                userInfoText = "ログインしていません";
              }
              return Text(userInfoText);
            },
          ),
          TextField(
            decoration: const InputDecoration(
              label: Text('駐車スキル'),
            ),
            controller: _skillController,
          ),
          ElevatedButton(
            child: Text('駐車スキル 編集'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .update({'skill': _skillController.text}); // データ
              infoText = "編集を完了しました";
            },
          ),
          const SizedBox(height: 8),
          Text(infoText),
        ]));
  }
}
