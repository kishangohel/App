import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/screens/welcome_screen/welcome_screen_footer_button.dart';

import 'introduction_screen/model/page_decoration.dart';
import 'introduction_screen/model/page_view_model.dart';

PageViewModel requestBackgroundLocationPageViewModel(
    BuildContext context, PageController controller) {
  return PageViewModel(
    useScrollView: false,
    title: "Auto Connect to WiFi",
    // bodyWidget has priority over body string.
    // Only build if location access is disabled.
    body: "VeriFi is trying to revolutionize how you connect to WiFi. " +
        "When you stop at a store, coffee shop, or other business, VeriFi " +
        "can automatically connect you to known WiFi access points.\n\n" +
        "In order to auto-connect to WiFi, VeriFi will need permission " +
        "to periodically retrieve your location in the background.",
    footer: WelcomeScreenFooterButton(
      initialButtonText: "Setup Background Location Access",
      initialAction: () => _enableBackgroundLocationServices(context),
      completedAction: () =>
          Navigator.of(context).pushReplacementNamed('/home'),
      completedButtonText: "Complete Setup",
    ),
    decoration: PageDecoration(
      bodyPadding: EdgeInsets.all(8.0),
      outerFlex: 1,
      bodyFlex: 2,
      contentMargin: EdgeInsets.all(12.0),
      fullScreen: true,
      pageColor: Theme.of(context).backgroundColor,
      titleTextStyle: Theme.of(context).textTheme.headline4!.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
    ),
  );
}

Future<void> _enableBackgroundLocationServices(BuildContext context) async {
  final request = await Permission.locationAlways.request();
  if (request.isDenied) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Warning!"),
        content: Text(
          "VeriFi auto-connect will be disabled. To re-enable, you " +
              "must set your location permissions to 'Always Allow'",
        ),
        actions: [
          TextButton(
            child: Text("Try Again"),
            onPressed: () async {
              Navigator.of(context).pop();
              Permission.locationAlways.request();
            },
          ),
          TextButton(
            child: Text("Continue without background location access"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
