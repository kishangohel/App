import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String labelText;
  final bool autofocus;
  final bool obscureText;
  final TextEditingController controller;

  const AuthTextField({
    required this.controller,
    required this.labelText,
    this.autofocus = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.bodyText2,
        autofocus: autofocus,
      ),
    );
  }
}
