import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'loginButton.dart';
import '../constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = Pages.mainPage;

  void _setIndex(value) {
    setState(() {
      _selectedIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case Pages.mainPage:
        page = Text('main page');

        break;
      case Pages.loginPage:
        page = LoginPage();
        break;
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
    return Scaffold(
      body: SafeArea(child: Container(child: page)),
      // floatingActionButton: LoginButton(setIndex: _setIndex),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.login), label: 'Login')
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          _setIndex(value);
        },
      ),
    );
  }
}
