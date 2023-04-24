import 'package:flutter/material.dart';
import 'loginPage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parking_app/screen/coffeePage.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('メインページ！'),
        ),
        body: Center(
          child: Column(children: [
            FloatingActionButton(
                child: Icon(Icons.coffee),
                onPressed: () {
                  Navigator.of(context).pushNamed("/coffee");
                }),
            ElevatedButton(
                child: Icon(Icons.login),
                onPressed: () {
                  Navigator.of(context).pushNamed("/login");
                }),
          ]),
        ));
  }
}
