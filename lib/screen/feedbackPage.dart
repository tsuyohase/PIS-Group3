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
        backgroundColor: Color.fromARGB(255, 215, 213, 213), 
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Feedback'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
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
                  userInfoText = 'Your Account' + snapshot.data!['email'];
                }
                //ログインしていない場合、その旨を表示.
              } else {
                isLogin = false;
                userInfoText = "Not logged in";
              }
              return Center(
                    child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 250,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: Border.all(color: Colors.green, width: 3.0),
                            borderRadius: BorderRadius.circular(8)),
                        child: RichText(
                          text: TextSpan(
                              style: const TextStyle(fontSize: 20),
                              children: [
                                const TextSpan(
                                    text: 'Your Current Account\n',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black)),
                                TextSpan(
                                    text: snapshot.data!.id != "hogehoge"
                                        ? snapshot.data!['email']
                                        : 'Not Logged In',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ]),
                          textAlign: TextAlign.center,
                        )),
                  );
            },
          ),
          const SizedBox(height: 8),
          //フィードバックする駐車場の名前を表示.
          const Text('Feedback parking diffculty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          Text('Name: ${widget.parking.name}'),
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
          const SizedBox(height: 16),
          //駐車場の画像をスライドで表示.
          CarouselSlider(
              options: CarouselOptions(),
              items: widget.parking.photoURLList.map((i) {
                return Image.network(i);
              }).toList()),
          const SizedBox(height: 8),
          //フィードバック送信ボタン.
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8)
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: const Text('Send', style: TextStyle(color: Colors.black)),
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
                  infoText = "Your feedback was sent.";
                });
                //ログインしていなければ、フィードバックは送信できない仕様.
              } else {
                setState(() {
                  infoText = "Your feedback can't be sent.\n(Not logged in)";
                });
              }
            },
          ),
          ),
          const SizedBox(height: 8),
          Text(infoText),
          //「ホームに戻る」ボタン.
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8)
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                child: const Text("Back", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  //ここではマップページに飛ぶ.
                  Navigator.of(context).pushNamed("/map");
                }),
          ),
        ]));
  }
}
