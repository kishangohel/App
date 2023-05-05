import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:verifi/src/common/widgets/bottom_button.dart';
import 'package:verifi/src/flutter_flow/flutter_flow_animations.dart';
import 'package:verifi/src/routing/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  final animationsMap = {
    'welcomeHeaderAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 1000.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'bodyFirstLineAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 1000.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 1000.ms,
          duration: 1200.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'bodySecondLineAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 3000.ms,
          duration: 1200.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'bodyThirdLineAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 5000.ms,
          duration: 1200.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'bottomButtonAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 7000.ms),
        FadeEffect(
          curve: Curves.easeIn,
          delay: 7000.ms,
          duration: 1000.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: AutoSizeText(
          'Welcome',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // WiFi rings animation
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Lottie.asset(
                        'assets/lottie_animations/wifi-rings.json',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 1,
                        fit: BoxFit.cover,
                        animate: true,
                      ),
                    ),
                  ],
                ),
              ),
              // Body text
              _animatedCenterText(context),
              // Bottom button
              BottomButton(
                // Navigate to features page
                onPressed: () => GoRouter.of(context).goNamed(
                  AppRoute.features.name,
                ),
                text: 'Join the Movement',
              ).animateOnPageLoad(animationsMap['bottomButtonAnimation']!)
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedCenterText(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'We are on a mission',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      textAlign: TextAlign.center,
                    ).animateOnPageLoad(
                        animationsMap['bodyFirstLineAnimation']!),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'To create the world\'s largest crowdsourced WiFi network',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      textAlign: TextAlign.center,
                    ).animateOnPageLoad(
                        animationsMap['bodySecondLineAnimation']!),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Revolutionizing how people connect around the world',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      textAlign: TextAlign.center,
                    ).animateOnPageLoad(
                        animationsMap['bodyThirdLineAnimation']!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
