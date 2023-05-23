import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'loginPage.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
  final userInfo =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  return userInfo;
}

Future<QuerySnapshot<Map<String, dynamic>>> getUserFeedbackInfo() async {
  final userFeedbackInfo = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .collection('parking\'s feedback')
      .get();
  return userFeedbackInfo;
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  bool skill = false;
  String userInfoText = "";
  String userSkillText = "";
  String userFeedbackText = "";
  String infoText = "";

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
                if (snapshot.data!['skillIsExpert']) {
                  userSkillText = '現在の駐車スキル：初心者ではない';
                } else {
                  userSkillText = '現在の駐車スキル：初心者';
                }
              } else {
                userSkillText = "ログインしていません";
              }
              return Text(userSkillText);
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 200,
            color: Colors.white,
            child: DropdownButton(
              hint: Text('駐車スキル変更'),
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
          ElevatedButton(
            child: Text('駐車スキル 編集'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .update({'skillIsExpert': skill}); // データ
              setState(() {
                infoText = "編集を完了しました";
              });
            },
          ),
          const SizedBox(height: 8),
          Text(infoText),
          const Text("駐車場へのフィードバック"),
          FutureBuilder(
            future: getUserFeedbackInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasData) {
                List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
                    snapshot.data!.docs;
                userFeedbackText = "";
                for (int i = 0; i < list.length; i++) {
                  var element = list[i];
                  userFeedbackText +=
                      "${i + 1} : ${element['time'].toDate()}\n${element.id}\n難易度評価 : ${element['difficulty']}\n";
                }
              } else {
                userFeedbackText = "なし";
              }
              return Text(userFeedbackText);
            },
          ),
        ]));
  }
}
