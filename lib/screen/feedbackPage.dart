import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:parking_app/screen/loginPage.dart';
import 'parking.dart';

String userInfoText = "";
String infoText = "";
bool ok = false;

Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
  final userInfo =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  return userInfo;
}

class FeedbackPage extends StatefulWidget {
  final Parking parking;
  const FeedbackPage({super.key, required this.parking});

  @override
  State<FeedbackPage> createState() => _FeedbackPage();
}

class _FeedbackPage extends State<FeedbackPage> {
  var _skillController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('口コミ'),
        ),
        body: Column(children: [
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                ok = true;
                userInfoText = 'ログイン中のアカウント：' + snapshot.data!['email'];
              } else {
                ok = false;
                userInfoText = "ログインしていません";
              }
              return Text(userInfoText);
            },
          ),
          TextField(
            decoration: const InputDecoration(
              label: Text('フィードバック'),
            ),
            controller: _skillController,
          ),
          ElevatedButton(
            child: const Text('送信'),
            onPressed: () async {
              if (ok) {
                await FirebaseFirestore.instance
                    .collection('users') // コレクションID
                    .doc(userID)
                    .collection('parkings')
                    .doc(widget.parking.name)
                    .set({
                  'time': DateTime.now(),
                  'text': _skillController.text
                });
                infoText = "フィードバックを送信しました";
              } else {
                infoText = "ログインしていないため送信できません";
              }
            },
          ),
          const SizedBox(height: 8),
          Text(infoText),
          Container(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: Text("ホームに戻る"),
                onPressed: () async {
                  Navigator.of(context).pushNamed("/map");
                }),
          ),
        ]));
  }
}
