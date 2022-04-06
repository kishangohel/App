import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/widgets/animated_text.dart';
import 'package:verifi/screens/welcome_screen/welcome_screen_footer_button.dart';

import 'introduction_screen/model/page_decoration.dart';
import 'introduction_screen/model/page_view_model.dart';

PageViewModel buildWelcomePageViewModel(
  BuildContext context,
  PageController pageController,
) {
  return PageViewModel(
    useScrollView: false,
    title: "Welcome to VeriFi",
    bodyWidget: Column(
      children: [
        Text(
          "Everyday, billions of people around the world are",
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        Container(
          margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
          height: 30,
          child: AnimatedText(
            wordList: [
              "connecting",
              "exploring",
              "researching",
              "traveling",
              "gaming",
              "relaxing",
              "socializing",
              "texting",
              "recovering",
              "messaging",
              "composing",
              "meditating",
              "producing",
            ],
            textStyle: Theme.of(context).textTheme.titleLarge,
            displayTime: const Duration(milliseconds: 800),
            speed: const Duration(milliseconds: 1200),
          ),
        ),
        Text(
          "with their phones, tablets, and laptops.\n",
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18.0),
          textAlign: TextAlign.start,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: "We believe free, public Internet is a ",
              ),
              TextSpan(
                text: "fundamental human right.\n\n",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      fontSize: 18.0,
                    ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(
                        'https://www.article19.org/data/files/Internet_Statement_Adopted.pdf',
                      ),
              ),
              TextSpan(
                text:
                    "Our mission is to provide all persons public Internet access from anywhere, at any time, for free.",
              ),
            ],
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 18.0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    decoration: PageDecoration(
      bodyPadding: EdgeInsets.all(8.0),
      outerFlex: 1,
      bodyFlex: 4,
      contentMargin: EdgeInsets.all(12.0),
      fullScreen: true,
      pageColor: Theme.of(context).backgroundColor,
      titleTextStyle: Theme.of(context).textTheme.headline4!.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
    ),
    footer: WelcomeScreenFooterButton(
      completedAction: () => pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      ),
      completedButtonText: "Continue",
    ),
  );
}
