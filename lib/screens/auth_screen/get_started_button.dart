import 'package:flutter/material.dart';
import 'package:verifi/screens/auth_screen/account_creation_screen.dart';

class GetStartedButton extends StatelessWidget {
  GetStartedButton() : super(key: UniqueKey());

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
