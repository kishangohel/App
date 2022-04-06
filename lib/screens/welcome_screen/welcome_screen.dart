import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/create_profile/create_profile_cubit.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/screens/welcome_screen/request_background_location_page_view_model.dart';
import 'package:verifi/screens/welcome_screen/request_location_page_view_model.dart';
import 'package:verifi/screens/welcome_screen/welcome_page_view_model.dart';
import 'package:verifi/widgets/intro_screen/create_profile_page.dart';

import 'introduction_screen/introduction_screen.dart';
import 'introduction_screen/model/page_decoration.dart';
import 'introduction_screen/model/page_view_model.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);

    return BlocListener<LocationCubit, LatLng?>(
      // Preemptively load WiFi feed once user accepts location permissions.
      listenWhen: (previous, current) {
        return (previous == null);
      },
      listener: (context, locationState) {
        if (locationState != null) {
          context.read<WifiFeedCubit>().loadFeed(locationState);
        }
      },
      child: WillPopScope(
        onWillPop: () => Future.value(false), // disable back button / gesture
        child: IntroductionScreen(
          freeze: true,
          pageController: pageController,
          globalHeader: Image.asset(
            'assets/wifi_city_4.gif',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
          ),
          pages: [
            buildWelcomePageViewModel(context, pageController),
            buildRequestLocationPageViewModel(context, pageController),
            requestBackgroundLocationPageViewModel(context, pageController),
          ],
          showDoneButton: false,
          showNextButton: false,
          dotsContainerDecorator:
              BoxDecoration(color: Theme.of(context).backgroundColor),
          dotsDecorator: DotsDecorator(
            activeColor: Theme.of(context).primaryColor,
            activeSize: Size.square(12.0),
          ),
        ),
      ),
    );
  }
}

PageViewModel _fourthIntroPage(BuildContext context) {
  return PageViewModel(
    title: "Create Your Profile",
    bodyWidget: CreateProfilePage(),
    footer: _buildCreateProfileFooter(context),
    decoration: PageDecoration(
      contentMargin: EdgeInsets.only(top: 55),
      pageColor: Theme.of(context).backgroundColor,
      titleTextStyle: Theme.of(context).textTheme.headline5!.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
    ),
  );
}

Widget _buildCreateProfileFooter(BuildContext context) {
  return BlocConsumer<CreateProfileCubit, Profile>(
    listener: (context, createProfileState) {
      if (createProfileState.status.isSubmissionSuccess) {
        sharedPrefs.setFirstLaunch();
        context.read<AuthenticationCubit>().refresh();
      }
    },
    builder: (context, createProfileState) {
      return Container(
        child: Visibility(
          visible: !(createProfileState.status.isPure ||
              createProfileState.status.isInvalid),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
            child: Text(
              "Create Profile",
              style: Theme.of(context).textTheme.button?.copyWith(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<CreateProfileCubit>().createProfile();
            },
          ),
        ),
      );
    },
  );
}
