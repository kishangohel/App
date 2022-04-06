import 'package:flutter/material.dart';

class SignInTextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      child: GestureDetector(
        child: Text(
          "Sign In",
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Colors.white,
                fontSize: 20.0,
              ),
          textAlign: TextAlign.center,
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/auth/login');
        },
      ),
    );
  }
}
