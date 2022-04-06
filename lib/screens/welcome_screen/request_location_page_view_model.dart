import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/screens/welcome_screen/welcome_screen_footer_button.dart';

import 'introduction_screen/model/page_decoration.dart';
import 'introduction_screen/model/page_view_model.dart';

PageViewModel buildRequestLocationPageViewModel(
  BuildContext context,
  PageController pageController,
) {
  return PageViewModel(
    title: "Location Based Connectivity",
    bodyWidget: Text(
      "In order for VeriFi to intelligently connect you to nearby WiFi, " +
          "we will periodically need access to your location.",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18.0),
      textAlign: TextAlign.center,
    ),
    footer: WelcomeScreenFooterButton(
      initialAction: () => _enableLocationServices(context),
      initialButtonText: "Enable Location Services",
      completedAction: () async {
        final granted = await Permission.locationWhenInUse.isGranted;
        if (granted) {
          pageController.animateToPage(
            2,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      },
      completedButtonText: "Continue",
    ),
    useScrollView: false,
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
  );
}

Future<void> _enableLocationServices(BuildContext context) async {
  final request = await Permission.locationWhenInUse.request();
  print(request.toString());
  if (request.isGranted) {
    context.read<LocationCubit>().getLocation();
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Warning!"),
        content: Text(
          "VeriFi will not function properly without location access.",
        ),
        actions: [
          TextButton(
            child: Text("Try Again"),
            onPressed: () async {
              Navigator.of(context).pop();
              final request = await Permission.locationWhenInUse.request();
              if (request.isGranted) {
                context.read<LocationCubit>().getLocation();
              }
            },
          ),
          TextButton(
            child: Text("Continue without location access"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _SecondPageFooter extends StatefulWidget {
  const _SecondPageFooter(PageController pageController);

  @override
  State<StatefulWidget> createState() => _SecondPageFooterState();
}

class _SecondPageFooterState extends State<_SecondPageFooter> {
  bool _locationDecided = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _locationDecided
        ? Text(
            "Swipe left to continue...",
            style: Theme.of(context).textTheme.caption,
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
            ),
            child: Text(
              "Enable Location Services",
              style: Theme.of(context).textTheme.button!.copyWith(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
            ),
            onPressed: () => _enableLocationServices(context),
          );
  }

  Future<void> _enableLocationServices(BuildContext context) async {
    final request = await Permission.locationWhenInUse.request();
    if (request.isGranted) {
      context.read<LocationCubit>().getLocation();
      setState(() {
        _locationDecided = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Warning!"),
          content: Text(
              "VeriFi will not function properly without location access."),
          actions: [
            TextButton(
              child: Text("Try Again"),
              onPressed: () async {
                Navigator.of(context).pop();
                final request = await Permission.locationWhenInUse.request();
                if (request.isGranted) {
                  context.read<LocationCubit>().getLocation();
                }
                setState(() {
                  _locationDecided = true;
                });
              },
            ),
            TextButton(
              child: Text("Continue without location access"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _locationDecided = true;
                });
              },
            ),
          ],
        ),
      );
    }
  }
}
