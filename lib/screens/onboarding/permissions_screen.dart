import 'dart:io';

import 'package:auto_connect/auto_connect.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/screens/onboarding/widgets/permission_request_row.dart';
import 'package:verifi/screens/onboarding/widgets/permissions_info_dialog.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

/// Screen to accept various permissions required by VeriFi.
///
class PermissionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  double opacity = 0;

  bool? _locationWhileInUse;
  bool? _locationAlways;
  bool? _activityRecognition;
  bool? _notifications;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
    _getCurrentPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(),
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            onBoardingBackground(context),
            _permissionsScreenContents(),
          ],
        ),
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
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PermissionRequestRow(
                    permissionName: "Location While Using App",
                    onChanged: (null == _locationWhileInUse)
                        ? _requestLocationWhileInUse
                        : null,
                    switchValue: _locationWhileInUse ?? false,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title: "Why does VeriFi need my location?",
                      contents:
                          '''\u2022  To automatically connect you to nearby WiFi access points.
\u2022  To show your location on the VeriMap.''',
                    ),
                  ),
                  PermissionRequestRow(
                    permissionName: "Background Location",
                    onChanged: (null == _locationAlways)
                        ? _requestLocationAlways
                        : null,
                    switchValue: _locationAlways ?? false,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title:
                          "Why does VeriFi need my location in the background?",
                      contents:
                          '''\u2022  Automatically connect you to nearby WiFi, even when the app is closed.
\u2022  Notify you in real time of nearby UnVeriFied WiFi that you can verify.
\u2022  Security and fraud prevention for contribution and validation actions.''',
                    ),
                  ),
                  PermissionRequestRow(
                    permissionName: "Activity Recognition",
                    onChanged: (null == _activityRecognition)
                        ? (Platform.isAndroid
                            ? _requestAndroidActivityRecognition
                            : _requestIOSActivityRecognition)
                        : null,
                    switchValue: _activityRecognition ?? false,
                    moreInfoDialog: const PermissionsInfoDialog(
                      title: "Why does VeriFi need to recognize my activity?",
                      contents:
                          '''\u2022 Conserve your battery (e.g. disable auto-connect while driving)
\u2022 More intelligently connect to nearby WiFi''',
                    ),
                  ),
                  // Only show notification row if iOS or Android >= 33
                  FutureBuilder<bool>(
                      future: _notificationsVisible(),
                      builder: (context, snapshot) {
                        return Visibility(
                          visible: (snapshot.data == true),
                          child: PermissionRequestRow(
                            permissionName: "Notifications",
                            onChanged: (null == _notifications)
                                ? (Platform.isAndroid
                                    ? _requestAndroidNotifications
                                    : _requestIOSNotifications)
                                : null,
                            switchValue: _notifications ?? false,
                            moreInfoDialog: const PermissionsInfoDialog(
                                title:
                                    "Why does VeriFi need to send me notifications?",
                                contents:
                                    '''\u2022 Notify you when you connect to an access point.
\u2022 Notify you when there's access points nearby for you to validate.'''),
                          ),
                        );
                      }),
                  _continueButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return Visibility(
      visible: _locationWhileInUse != null &&
          _locationAlways != null &&
          _activityRecognition != null &&
          _notifications != null,
      child: OnboardingOutlineButton(
        onPressed: () async {
          // Set flag for routing to skip this page in future
          await sharedPrefs.setPermissionsComplete();
          final displayName = context.read<ProfileCubit>().displayName;
          final wallets =
              await context.read<WalletConnectCubit>().getAvailableWallets();
          // If displayName is not set, continue onboarding
          if (displayName == null) {
            // Web3 onboarding
            if (wallets.isNotEmpty) {
              await Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding/readyWeb3',
                ModalRoute.withName('onboarding/'),
              );
              // Web2 onboarding
            } else {
              await Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding/terms',
                ModalRoute.withName('/onboarding'),
              );
            }
            // If display name is not null, profile is complete.
            // Navigate to final setup page.
          } else {
            await Navigator.of(context).pushNamedAndRemoveUntil(
              '/onboarding/finalSetup',
              ModalRoute.withName('onboarding/'),
            );
          }
        },
        text: "Continue",
      ),
    );
  }

  Future<void> _getCurrentPermissions() async {
    final locationWhenInUseGranted =
        await Permission.locationWhenInUse.isGranted;
    if (true == locationWhenInUseGranted) {
      setState(() => _locationWhileInUse = true);
    }
    final locationAlwaysGranted = await Permission.locationAlways.isGranted;
    if (locationAlwaysGranted) {
      setState(() => _locationAlways = true);
    }
    if (Platform.isAndroid) {
      final activityRecognitionGranted =
          await Permission.activityRecognition.isGranted;
      if (activityRecognitionGranted) {
        setState(() => _activityRecognition = true);
      }
    } else {
      final activityRecognitionGranted = await Permission.sensors.isGranted;
      if (activityRecognitionGranted) {
        setState(() => _activityRecognition = true);
      }
    }
    if (Platform.isIOS) {
      final notificationsGranted = await Permission.notification.isGranted;
      if (notificationsGranted) {
        setState(() => _notifications = true);
      }
    } else {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        final notifications = FlutterLocalNotificationsPlugin();
        final notificationsGranted = await notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        if (notificationsGranted == true) {
          setState(() => _notifications = true);
        }
      }
    }
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

  /// Requests location while in use permission from user.
  Future<void> _requestLocationWhileInUse() async {
    final status = await Permission.locationWhenInUse.request();
    debugPrint("Location when in use permission: ${status.toString()}");

    switch (status) {

      // If user permanently denied location when in use
      // set both locationWhenInUse and locationAlways to false
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        setState(() {
          _locationWhileInUse = false;
          _locationAlways = false;
        });
        break;

      // If user grants permission, set locationWhenInUse to true
      case PermissionStatus.granted:
        setState(() {
          _locationWhileInUse = true;
        });
        break;

      // If denied (but not permanently denied), do nothing so user has
      // ability to try again
      case PermissionStatus.denied:
      default:
        break;
    }
  }

  /// Requests background location permission from the user.
  Future<void> _requestLocationAlways() async {
    final status = await Permission.locationAlways.request();
    debugPrint("Location always permission: ${status.toString()}");

    switch (status) {

      // If user permanently denied location always
      // set locationAlways to false
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        setState(() {
          _locationAlways = false;
        });
        break;

      // If user grants permission, set locationAlways to true
      case PermissionStatus.granted:
        setState(() {
          _locationAlways = true;
        });
        break;

      // If denied (but not permanently denied), do nothing so user has
      // ability to try again
      case PermissionStatus.denied:
      default:
        break;
    }
  }

  /// Requests Android activity recognition permission from user.
  Future<void> _requestAndroidActivityRecognition() async {
    final status = await Permission.activityRecognition.request();
    debugPrint("Activity recognition permission: ${status.toString()}");

    switch (status) {

      // If user permanently denied location always
      // set locationAlways to false
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        setState(() {
          _activityRecognition = false;
        });
        break;

      // If user grants permission, set locationAlways to true
      case PermissionStatus.granted:
        setState(() {
          _activityRecognition = true;
        });
        break;

      // If denied (but not permanently denied), do nothing so user has
      // ability to try again
      case PermissionStatus.denied:
      default:
        break;
    }
  }

  /// Requests iOS activity recognition permission from user.
  Future<void> _requestIOSActivityRecognition() async {
    final status = await Permission.sensors.request();
    debugPrint("Activity recognition permission: ${status.toString()}");

    switch (status) {

      // If user permanently denied location always
      // set locationAlways to false
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        setState(() {
          _activityRecognition = false;
        });
        break;

      // If user grants permission, set locationAlways to true
      case PermissionStatus.granted:
        setState(() {
          _activityRecognition = true;
        });
        await AutoConnect.startActivityMonitoring();
        break;

      // If denied (but not permanently denied), do nothing so user has
      // ability to try again
      case PermissionStatus.denied:
      default:
        break;
    }
  }

  Future<void> _requestAndroidNotifications() async {
    final notifications = FlutterLocalNotificationsPlugin();
    final status = await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    setState(() => _notifications = status);
  }

  Future<void> _requestIOSNotifications() async {
    final status = await Permission.notification.request();
    debugPrint("Notification permission: ${status.toString()}");

    switch (status) {

      // If user permanently denied location always
      // set locationAlways to false
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        setState(() {
          _notifications = false;
        });
        break;

      // If user grants permission, set locationAlways to true
      case PermissionStatus.granted:
        setState(() {
          _notifications = true;
        });
        break;

      // If denied (but not permanently denied), do nothing so user has
      // ability to try again
      case PermissionStatus.denied:
      default:
        break;
    }
  }

  Future<bool> _notificationsVisible() async {
    if (Platform.isIOS) return true;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt >= 33) {
      return true;
    }
    // if notification permissions do not need to be requested, then we must
    // set _notifications to true. Otherwise, _continueButton will not become
    // visible.
    setState(() {
      _notifications = true;
    });
    return false;
  }
}
