import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/auth_screen/account_creation_screen.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listenWhen: (previous, current) {
        return previous.user == null && current.user != null;
      },
      listener: (context, state) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      },
      child: _IntroScreenScaffold(),
    );
  }
}

class _IntroScreenScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _IntroTextContent(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _GetStartedButton(),
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

class _IntroTextContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Hero(
                tag: 'verifi-title',
                child: AppTitle(
                  fontSize: 72,
                  fontColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.topCenter,
            child: SizedBox(
              child: Text(
                "Bridging the Universe with the Metaverse",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
        child: Text(
          "Begin the journey",
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1, milliseconds: 500),
              reverseTransitionDuration: const Duration(seconds: 1),
              transitionsBuilder: _slideTransition,
              pageBuilder: (BuildContext context, _, __) =>
                  AccountCreationScreen(),
            ),
          );
        }
        /* onPressed: () => showBottomSheet( */
        /*   context: context, */
        /*   builder: (BuildContext context) { */
        /*     return OnboardingSheet(); */
        /*   }, */
        /*   backgroundColor: Theme.of(context).backgroundColor, */
        /*   shape: RoundedRectangleBorder( */
        /*     borderRadius: BorderRadius.circular(12.0), */
        /*   ), */
        /*   enableDrag: false, */
        /* ), */
        );
  }

  SlideTransition _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}
