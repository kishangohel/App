import 'package:flutter/material.dart';

class NewUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New User",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: Container(
        child: Text("Meow"),
      ),
    );
  }
}
