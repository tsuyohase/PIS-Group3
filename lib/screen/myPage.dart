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

class _MyPage extends State<MyPage> {
  bool skill = false;
  String userInfoText = "";
  String userSkillText = "";
  String userFeedbackText = "";
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 215, 213, 213),
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('My Page', style: TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    ///border: Border.all(color: Colors.black.withOpacity(0.5), width: 4),
                    ///borderRadius: BorderRadius.circular(8),
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
              Text('App Title',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold))
                ]),
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                userInfoText = 'Your Current Account:\n${snapshot.data!['email']}';
              } else {
                userInfoText = "Not Logged In";
              }
              return Center(
                child: Container(
                margin: EdgeInsets.all(8),
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.green, width: 3.0),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 20),
                    children: [
                      TextSpan(
                        text: 'Your Current Account\n',
                        style: TextStyle(fontSize: 12, color: Colors.black)
                        ),
                      TextSpan(
                        text: snapshot.hasData ? snapshot.data!['email'] : 'Not Logged In',
                        style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold))
                    ]),
                  textAlign: TextAlign.center,
                  )
                ),
              );
            },
          ),
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!['skillIsExpert']) {
                  userSkillText = 'Driver Skill: Expert';
                } else {
                  userSkillText = 'Driver Skill: Beginner';
                }
              } else {
                userSkillText = "Not Logged In";
              }
              return Center(
                child: Container(
                  margin: EdgeInsets.all(8),
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green, width: 3.0),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        TextSpan(text: 'Your Skill\n'),
                        TextSpan(
                          text: snapshot.hasData
                          ? (snapshot.data!['skillIsExpert'] ? 'Expert' : 'Beginner')
                          : 'Not Logged In',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          Center(
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              ),
            child: DropdownButton(
              underline: Container(),
              items: const [
                DropdownMenuItem(
                  child: Text('Beginner', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: false,
                ),
                DropdownMenuItem(
                  child: Text('Expert', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),
          Center(
          child: Container(
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: Text('Modify Your Skill', style: TextStyle(color: Colors.black)),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .update({'skillIsExpert': skill}); // データ);
            },
          ),
          ),
          ),
          const SizedBox(height: 16),
          Text("Your Feedback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      "${i + 1} : ${element['time'].toDate()}\n${element.id}\nDifficulty : ${element['difficulty']}\n";
                }
              } else {
                userFeedbackText = "None";
              }
              return Text(userFeedbackText);
            },
          ),
        ])));
  }
}
