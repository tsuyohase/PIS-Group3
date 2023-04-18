import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.setIndex});

  final void Function(int) setIndex;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setIndex(Pages.loginPage);
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}
