import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}
