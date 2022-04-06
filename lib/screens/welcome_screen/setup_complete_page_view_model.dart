import 'package:flutter/material.dart';
import 'package:verifi/screens/welcome_screen/introduction_screen/model/page_view_model.dart';
import 'package:verifi/screens/welcome_screen/welcome_screen_footer_button.dart';

PageViewModel buildSetupCompletePageViewModel(BuildContext context) {
  return PageViewModel(
      title: "Setup Complete",
      body: "Now it is time to set up your account.",
      footer: WelcomeScreenFooterButton(
        initialButtonText: "Complete Setup",
        initialAction: () =>
            Navigator.of(context).pushReplacementNamed('/auth'),
        completedAction: () {},
        completedButtonText: "Complete Setup",
      ));
}
