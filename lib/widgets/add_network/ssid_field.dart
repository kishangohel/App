import 'package:flutter/material.dart';

class SSIDField extends StatelessWidget {
  final TextEditingController _textEditingController;
  const SSIDField(this._textEditingController);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Network Name",
        ),
        controller: _textEditingController,
      ),
    );
  }
}
