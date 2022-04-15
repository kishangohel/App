import 'package:flutter/material.dart';
import 'package:verifi/widgets/animated_text.dart';

class OnboardingSheet extends StatelessWidget {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: PageView(
        controller: controller,
        children: [
          OnboardingFirstPage(),
          const Text("Two"),
          const Text("Three"),
        ],
      ),
    );
  }
}

class OnboardingFirstPage extends StatelessWidget {
  final _topText = "We are committed to bridging the artificial divide "
      "between the physical universe and the digital metaverse.";
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Welcome to VeriFi",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Text(
              _topText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 18.0),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Everyday, billions of people around the world are",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 4.0),
              height: 20,
              child: AnimatedText(
                wordList: const [
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
                alignment: Alignment.topCenter,
                textStyle: Theme.of(context).textTheme.titleLarge,
                displayTime: const Duration(milliseconds: 800),
                speed: const Duration(milliseconds: 1200),
              ),
            ),
            Text(
              "with their phones, tablets, and laptops.\n",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 18.0),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "To improve the user experience across these pursuits, "
                "we provide three core services to our community:",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 18.0),
              ),
            ),
            Text(
              "1) Connection to the Metaverse\n2) Connection in the Universe\n"
              "3) Bridging the Universe with the Metaverse",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }
}
