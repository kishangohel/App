import 'package:flutter/material.dart';

class GetStartedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 14.0,
          ),
        ),
        child: Text(
          "Get Started",
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/auth/register');
        },
      ),
    );
  }
}
