import 'package:flutter/material.dart';

class SignInTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
