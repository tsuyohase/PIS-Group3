import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parking_app/screen/homePage.dart';
import 'package:parking_app/screen/coffeePage.dart';
import 'package:parking_app/screen/loginPage.dart';
import 'package:parking_app/screen/map.dart';
import 'package:parking_app/screen/registerPage.dart';

void main() async {
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
        '/register': (BuildContext context) => new RegisterPage()
      },
    );
  }
}
