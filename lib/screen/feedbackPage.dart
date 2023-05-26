import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_hoisLogins/flutter_hoisLogins.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parking_app/screen/loginPage.dart';
import 'parking.dart';
import 'package:http/http.dart' as http;

//ログインしているかどうかを表示するメッセージ.
String userInfoText = "";
//マイページの編集を完了したなどのメッセージ.
String infoText = "";
//ログインしているかどうか.
bool isLogin = false;
//フィードバックする際の駐車難易度（0.0~5.0）.
double difficulty = 0.0;

//ログインしているユーザーの情報を取得
Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() {
  //ログインしていない場合、架空のユーザーとして仮設定.
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
          title: const Text('フィードバックページ'),
        ),
        body: Column(children: [
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              //ログインしている場合、アカウントのe-mailアドレスを表示.
              if (snapshot.data != null) {
                //架空ログインではないことを確認
                if (snapshot.data!.id != "hogehoge") {
                  isLogin = true;
                  // ignore: prefer_interpolation_to_compose_strings
                  userInfoText = 'ログイン中のアカウント：' + snapshot.data!['email'];
                }
                //ログインしていない場合、その旨を表示.
              } else {
                isLogin = false;
                userInfoText = "ログインしていません";
              }
              return Text(userInfoText);
            },
          ),
          //フィードバックする駐車場の名前を表示.
          const Text('駐車難易度のフィードバック'),
          Text('駐車場：${widget.parking.name}'),
          //タップで評価できるアイコンを表示（5段階）.
          RatingBar.builder(
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, index) {
              switch (index) {
                case 4:
                  return const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 3:
                  return const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 1:
                  return const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 0:
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
          //評価しようとしている数値を表示.
          Text('difficulty: $difficulty'),
          //駐車場の画像をスライドで表示.
          CarouselSlider(
              options: CarouselOptions(),
              items: widget.parking.photoURLList.map((i) {
                return Image.network(i);
              }).toList()),
          //フィードバック送信ボタン.
          ElevatedButton(
            child: const Text('送信'),
            onPressed: () async {
              //ログインしていれば、フィードバックをデータベースに格納.
              if (isLogin) {
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
                //ログインしていなければ、フィードバックは送信できない仕様.
              } else {
                setState(() {
                  infoText = "ログインしていないため送信できません";
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(infoText),
          //「ホームに戻る」ボタン.
          Container(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: const Text("ホームに戻る"),
                onPressed: () async {
                  //ここではマップページに飛ぶ.
                  Navigator.of(context).pushNamed("/map");
                }),
          ),
        ]));
  }
}
