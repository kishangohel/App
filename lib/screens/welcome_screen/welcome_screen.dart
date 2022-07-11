import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/welcome_screen/request_background_location_page_view_model.dart';
import 'package:verifi/screens/welcome_screen/request_location_page_view_model.dart';
import 'package:verifi/screens/welcome_screen/welcome_page_view_model.dart';

import 'introduction_screen/introduction_screen.dart';

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
            'assets/enter_the_metaverse.gif',
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
            activeSize: const Size.square(12.0),
          ),
        ),
      ),
    );
  }
}
