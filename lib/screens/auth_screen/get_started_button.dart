import 'package:flutter/material.dart';

class GetStartedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
      ),
      child: Text(
        "Begin the journey",
        style: Theme.of(context).textTheme.button?.copyWith(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/auth/register');
      },
    );
  }
}
