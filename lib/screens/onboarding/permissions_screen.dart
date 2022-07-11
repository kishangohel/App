import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/widgets/permission_request_row.dart';
import 'package:verifi/widgets/text/app_title.dart';

class PermissionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: const Hero(
          tag: 'verifi-title',
          child: AppTitle(
            fontSize: 48.0,
            textAlign: TextAlign.center,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            PermissionRequestRow(
              onChanged: (bool changed) {},
            ),
          ],
        ),
      ),
    );
  }
}
