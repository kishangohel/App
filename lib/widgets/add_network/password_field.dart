import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController _textEditingController;
  const PasswordField(this._textEditingController);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Password",
        ),
        controller: _textEditingController,
      ),
    );
  }
}
