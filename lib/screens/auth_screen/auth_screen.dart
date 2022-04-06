import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/auth_screen/get_started_button.dart';
import 'package:verifi/screens/auth_screen/intro_text_content.dart';
import 'package:verifi/screens/auth_screen/social_auth_buttons.dart';
import 'package:verifi/screens/auth_screen/social_auth_divider.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listenWhen: (previous, current) {
        return previous.user == null && current.user != null;
      },
      listener: (context, state) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/enter_the_metaverse.gif',
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: IntroTextContent(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        GetStartedButton(),
                        /* SocialAuthDivider(), */
                        /* SocialAuthButtons(), */
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
