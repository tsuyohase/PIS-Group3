import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parking_app/screen/loginPage.dart';
import 'parking.dart';

String userInfoText = "";
String infoText = "";
bool ok = false;
double difficulty = 0.0;

Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() {
  if (userID == "") {
    userID = "hogehoge";
  }
  final userInfo =
      FirebaseFirestore.instance.collection('users').doc(userID).get();
  return userInfo;
}

class FeedbackPage extends StatefulWidget {
  final Parking parking;
  const FeedbackPage({super.key, required this.parking});

  @override
  State<FeedbackPage> createState() => _FeedbackPage();
}

class _FeedbackPage extends State<FeedbackPage> {
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
              if (snapshot.data != null) {
                if (snapshot.data!.id != "hogehoge") {
                  ok = true;
                  userInfoText = 'ログイン中のアカウント：' + snapshot.data!['email'];
                }
              } else {
                ok = false;
                userInfoText = "ログインしていません";
              }
              return Text(userInfoText);
            },
          ),
          Text('駐車場：${widget.parking.name}'),
          const Text('駐車難易度のフィードバック'),
          RatingBar.builder(
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 1:
                  return const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 3:
                  return const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 4:
                  return const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  );
                default:
                  return const Icon(
                    Icons.star,
                    color: Colors.yellow,
                  );
              }
            },
            onRatingUpdate: (rating) {
              setState(() {
                difficulty = rating;
              });
            },
          ),
          Text('difficlty: ${difficulty}'),
          ElevatedButton(
            child: const Text('送信'),
            onPressed: () async {
              if (ok) {
                await FirebaseFirestore.instance
                    .collection('users') // コレクションID
                    .doc(userID)
                    .collection('parking\'s feedback')
                    .doc(widget.parking.name)
                    .set({
                  'time': DateTime.now(),
                  'difficulty': difficulty,
                });
                setState(() {
                  infoText = "フィードバックを送信しました";
                });
              } else {
                setState(() {
                  infoText = "ログインしていないため送信できません";
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(infoText),
          Container(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: const Text("ホームに戻る"),
                onPressed: () async {
                  Navigator.of(context).pushNamed("/map");
                }),
          ),
        ]));
  }
}
