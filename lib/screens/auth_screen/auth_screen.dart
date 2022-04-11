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
      child: _InitialScreenScaffold(),
    );
  }
}

class _InitialScreenScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Hero(
                tag: 'enter-the-metaverse',
                child: Image.asset(
                  'assets/enter_the_metaverse.gif',
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Hero(
                tag: 'enter-the-metaverse-filter',
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
