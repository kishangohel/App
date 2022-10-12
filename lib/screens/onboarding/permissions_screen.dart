import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/screens/onboarding/widgets/permission_request_row.dart';
import 'package:verifi/screens/onboarding/widgets/permissions_info_dialog.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class PermissionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PermissionsScreenState();
}

/// Screen to accept location permissions and activity recognition permissions.
/// If user closes app, then they are automatically logged out via
/// [WillPopScope] override.
class _PermissionsScreenState extends State<PermissionsScreen> {
  double opacity = 0;
  Color textColor = Colors.black;

  bool _backgroundLocationSelected = false;
  // By default we disable location always switch
  // until background location is permitted
  bool _locationAlwaysSelected = true;
  bool _activityRecognitionSelected = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If profile is empty, it is because iOS cached the phone credentials.
    // We need to manually pull existing profile or create a new one,
    // depending on whether user finished onboarding.
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: WillPopScope(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _permissionsScreenContents(),
            ],
          ),
        ),
        onWillPop: () async {
          await context.read<AuthenticationCubit>().logout();
          context.read<ProfileCubit>().logout();
          await context.read<ProfileCubit>().clear();
          return true;
        },
      ),
    );
  }

  Widget _permissionsScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _permissionsDescriptionText(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PermissionRequestRow(
                    permissionName: "Location While Using App",
                    onChanged: (_backgroundLocationSelected == false)
                        ? _requestBackgroundLocation
                        : null,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title: "Why does VeriFi need my location?",
                      contents: '''\u2022 Identify nearby WiFi access points
\u2022 Show your location on the VeriMap
\u2022 Ensure accurate calculation of incentives''',
                    ),
                  ),
                  PermissionRequestRow(
                    permissionName: "Background Location",
                    onChanged: (_locationAlwaysSelected == false)
                        ? _requestLocationAlways
                        : null,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title: "Why does VeriFi need my location all the time?",
                      contents:
                          '''\u2022 Automatically connect you to nearby WiFi at all times 
\u2022 Notify you in real time of nearby opportunities to receive additional rewards.''',
                    ),
                  ),
                  PermissionRequestRow(
                    permissionName: "Activity Recognition",
                    onChanged: (_activityRecognitionSelected == false)
                        ? _requestActivityRecognition
                        : null,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title: "Why does VeriFi need to recognize my activity?",
                      contents:
                          '''\u2022 Conserve your battery (e.g. disable auto-connect while driving)
\u2022 More intelligently connect to nearby WiFi''',
                    ),
                  ),
                  _finishPermissionsButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _finishPermissionsButton() {
    return OnboardingOutlineButton(
      onPressed: () async {
        final displayName = context.read<ProfileCubit>().displayName;
        if (displayName == null) {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding/readyWeb3',
            ModalRoute.withName('onboarding/'),
          );
        } else {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding/finalSetup',
            ModalRoute.withName('onboarding/'),
          );
        }
      },
      text: "Finish",
    );
  }

  Widget _permissionsDescriptionText() {
    return Text(
      "The following permissions are required for VeriFi to intelligently "
      "connect to nearby WiFi access points",
      style: Theme.of(context)
          .textTheme
          .headline5
          ?.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    );
  }

  /// Requests background location permissions from user.
  /// Returns true if user granted permission, false otherwise.
  Future<bool> _requestBackgroundLocation() async {
    bool permitted = false;
    final status = await Permission.locationWhenInUse.request();

    switch (status) {
      case PermissionStatus.denied:
        permitted = false;
        break;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        permitted = false;
        setState(() {
          _backgroundLocationSelected = true;
          _locationAlwaysSelected = true;
        });
        break;

      case PermissionStatus.granted:
        permitted = true;
        setState(() {
          _backgroundLocationSelected = true;
          _locationAlwaysSelected = false;
        });
        break;

      default:
        break;
    }

    return permitted;
  }

  Future<bool> _requestLocationAlways() async {
    bool permitted = false;
    final status = await Permission.locationAlways.request();

    switch (status) {
      case PermissionStatus.denied:
        permitted = false;
        break;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        permitted = false;
        setState(() {
          _locationAlwaysSelected = true;
        });
        break;

      case PermissionStatus.granted:
        permitted = true;
        setState(() {
          _locationAlwaysSelected = true;
        });
        break;

      default:
        break;
    }

    return permitted;
  }

  /// Requests activity recognition permissions from user.
  /// Returns true if user granted permission, false otherwise.
  Future<bool> _requestActivityRecognition() async {
    bool permitted = false;
    PermissionStatus status = PermissionStatus.denied;

    if (Platform.isIOS) {
      status = await Permission.sensors.request();
    } else if (Platform.isAndroid) {
      status = await Permission.activityRecognition.request();
    }

    switch (status) {
      case PermissionStatus.denied:
        permitted = false;
        break;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        permitted = false;
        setState(() {
          _activityRecognitionSelected = true;
        });
        break;

      case PermissionStatus.granted:
        permitted = true;
        setState(() {
          _activityRecognitionSelected = true;
        });
        break;

      default:
        break;
    }

    return permitted;
  }
}
