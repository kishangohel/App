import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/blocs/blocs.dart';

class SocialAuthButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          /* _buildFacebookButton(context), */
          /* _buildGoogleButton(context), */
          /* _buildTwitterButton(context), */
          /* _buildEmailButton(context), */
        ],
      ),
    );
  }

  /* Widget _buildFacebookButton(BuildContext context) { */
  /*   return Container( */
  /*     width: 48.0, */
  /*     height: 48.0, */
  /*     child: ElevatedButton( */
  /*       style: ElevatedButton.styleFrom( */
  /*         primary: Color(0xFF1877f2), */
  /*         shape: ContinuousRectangleBorder( */
  /*           borderRadius: BorderRadius.circular(8.0), */
  /*         ), */
  /*         padding: EdgeInsets.all(8.0), */
  /*       ), */
  /*       child: Image( */
  /*         image: AssetImage('assets/social_media_icons/facebook_new.png'), */
  /*       ), */
  /*       onPressed: () {}, */
  /*     ), */
  /*   ); */
  /* } */

  Widget _buildTwitterButton(BuildContext context) {
    return Container(
      width: 48.0,
      height: 48.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(8.0),
          primary: Color(0xFF1DA1F2),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Icon(
          FontAwesomeIcons.twitter,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return Container(
      height: 48.0,
      width: 48.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).colorScheme.secondary,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        child: Icon(Icons.email),
        onPressed: () {
          Navigator.of(context).pushNamed('/auth/login');
        },
      ),
    );
  }
}
