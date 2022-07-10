import 'package:flutter/material.dart';
import 'package:verifi/widgets/text/app_title.dart';

class ProfilePictureSelectScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePictureSelectState();
}

class _ProfilePictureSelectState extends State<ProfilePictureSelectScreen> {
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
      body: SafeArea(
        child: Stack(
          children: [
            _profilePictureScreenContents(),
          ],
        ),
      ),
    );
  }

  Widget _profilePictureScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Container(color: Colors.white),
    );
  }
}
