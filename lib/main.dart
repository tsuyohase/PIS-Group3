import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parking_app/screen/myPage.dart';
import 'package:parking_app/screen/navitimePage.dart';
import 'firebase_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parking_app/screen/homePage.dart';
import 'package:parking_app/screen/coffeePage.dart';
import 'package:parking_app/screen/loginPage.dart';
import 'package:parking_app/screen/map.dart';
import 'package:parking_app/screen/registerPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:parking_app/screen/rankingPage.dart";
import 'package:parking_app/screen/parking.dart';
import "package:parking_app/screen/naviPage.dart";

import 'screen/machineLearningPage.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(ProviderScope(child: MyApp()));
}

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initFirebase();
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => new HomePage(),
          '/coffee': (BuildContext context) => new CoffeePage(),
          '/login': (BuildContext context) => new LoginPage(),
          '/map': (BuildContext context) => new GoogleMapWidget(),
          '/register': (BuildContext context) => new RegisterPage(),
          '/navitime': (BuildContext context) => new NavitimePage(),
          '/mypage': (BuildContext context) => new MyPage(),
          '/ranking': (BuildContext context) => new RankingPage(
              parkings: ModalRoute.of(context)!.settings.arguments
                  as ValueNotifier<List<Parking>>),
          '/navi': (BuildContext context) => new NaviPage(
              parking: ModalRoute.of(context)!.settings.arguments as Parking),
          '/mlpage': (BuildContext context) => new MachineLearningPage(),
        });
  }
}
