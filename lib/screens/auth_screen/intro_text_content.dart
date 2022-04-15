import 'package:flutter/material.dart';
import 'package:verifi/widgets/text/app_title.dart';

class IntroTextContent extends StatelessWidget {
  IntroTextContent() : super(key: UniqueKey());

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
