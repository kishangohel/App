import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/auth_screen/get_started_button.dart';
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
              'assets/wifi_city_4.gif',
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
            ),
            Container(
              color: Colors.black.withOpacity(0.28),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "VeriFi",
                          style:
                              Theme.of(context).textTheme.bodyText2?.copyWith(
                                    fontSize: 72.0,
                                    color: Colors.white,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Container(
                        child: Text(
                          "Bridging the Universe with the Metaverse",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyText2?.copyWith(
                                    fontSize: 22.0,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        GetStartedButton(),
                        SocialAuthDivider(),
                        SocialAuthButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        /* body: Container( */
        /*   color: Theme.of(context).primaryColor, */
        /*   height: MediaQuery.of(context).size.height, */
        /*   padding: EdgeInsets.all(32.0), */
        /*   child: Column( */
        /*     children: [ */
        /*       Expanded( */
        /*         flex: 3, */
        /*         child: Container( */
        /*           alignment: Alignment.bottomCenter, */
        /*           child: Text( */
        /*             "VeriFi", */
        /*             style: Theme.of(context).textTheme.bodyText2?.copyWith( */
        /*                   fontSize: 72.0, */
        /*                 ), */
        /*             textAlign: TextAlign.center, */
        /*           ), */
        /*         ), */
        /*       ), */
        /*       Expanded( */
        /*         flex: 3, */
        /*         child: Container( */
        /*           alignment: Alignment.topCenter, */
        /*           child: Text( */
        /*             "Bridging the Universe with the Metaverse", */
        /*             textAlign: TextAlign.center, */
        /*             style: Theme.of(context).textTheme.bodyText2?.copyWith( */
        /*                   fontSize: 22.0, */
        /*                 ), */
        /*           ), */
        /*         ), */
        /*       ), */
        /*       Expanded( */
        /*         flex: 3, */
        /*         child: Column( */
        /*           children: [ */
        /*             GetStartedButton(), */
        /*             SocialAuthDivider(), */
        /*             SocialAuthButtons(), */
        /*           ], */
        /*         ), */
        /*       ), */
        /*     ], */
        /*   ), */
        /* ), */
      ),
    );
  }
}
