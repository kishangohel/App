import 'package:flutter/material.dart';
import 'package:verifi/src/features/profile/presentation/profile_app_bar.dart';
import 'package:verifi/src/features/profile/presentation/profile_body.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(),
      body: ProfileBody(),
    );
  }
}
