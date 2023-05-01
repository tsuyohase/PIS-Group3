import 'package:flutter/material.dart';
import 'loginPage.dart';

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
        body: Center(
          child: Column(children: [
            Text(email.toString()),
            TextField(
              decoration: const InputDecoration(
                label: Text('駐車スキル'),
              ),
              controller: _skillController,
            ),
          ]),
        ));
  }
}
