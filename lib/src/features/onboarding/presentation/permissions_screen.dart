import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:verifi/src/common/widgets/bottom_button.dart';
import 'package:verifi/src/features/onboarding/data/onboarding_state_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  final switchState = <String, bool?>{};

  Future<void> _requestLocationPermissions(bool value) async {
    final status = await Permission.locationWhenInUse.request();
    setState(() => switchState['location'] = status.isGranted);
  }

  Future<void> _requestLocationBackgroundPermissions(bool value) async {
    final status = await Permission.locationAlways.request();
    setState(() => switchState['locationBackground'] = status.isGranted);
  }

  Future<void> _requestNotificationPermissions(bool value) async {
    final status = await Permission.notification.request();
    setState(() => switchState['notifications'] = status.isGranted);
  }

  Future<void> _requestActivityRecognitionPermissions(bool value) async {
    PermissionStatus status = PermissionStatus.denied;
    if (Platform.isAndroid) {
      status = await Permission.activityRecognition.request();
    } else if (Platform.isIOS) {
      status = await Permission.sensors.request();
    }
    setState(() => switchState['activityRecognition'] = status.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      'Permissions',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              // Map animation
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        child: Lottie.asset(
                          'assets/lottie_animations/wifi_map.json',
                          fit: BoxFit.fitHeight,
                          animate: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Description
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'VeriFi requires additional permissions for certain features. '
                        'Please toggle & approve each permission to unlock those features.',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              // Permission cards
              _permissionSwitchListTiles(),
              // Accept & Continue button
              Visibility(
                visible: switchState.length == 4,
                child: BottomButton(
                  onPressed: () async =>
                      ref.read(onboardingStateProvider.notifier).complete(),
                  text: 'Accept & Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionSwitchListTiles() {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location switch list tile
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: SwitchListTile.adaptive(
                  value: switchState["location"] == true,
                  onChanged: (switchState['location'] != null)
                      ? null
                      : (value) => _requestLocationPermissions(value),
                  title: const Text(
                    'Location',
                  ),
                  subtitle: const Text(
                    'View and connect to nearby access points',
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Background location switch list tile
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: SwitchListTile.adaptive(
                  value: switchState["locationBackground"] == true,
                  onChanged: (switchState["locationBackground"] != null)
                      ? null
                      : (value) => _requestLocationBackgroundPermissions(value),
                  title: const Text(
                    'Background Location',
                  ),
                  subtitle: const Text(
                    'View and connect to nearby access points when the app is not open',
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Notifications switch list tile
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: SwitchListTile.adaptive(
                  value: switchState["notifications"] == true,
                  onChanged: (switchState["notifications"] != null)
                      ? null
                      : (value) => _requestNotificationPermissions(value),
                  title: const Text(
                    'Notifications',
                  ),
                  subtitle: const Text(
                    'Know about reward opportunities, earned achievements, and other important information.',
                  ),
                  tileColor: Theme.of(context).colorScheme.background,
                  activeColor: Theme.of(context).colorScheme.primary,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Activity recognition switch list tile
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: SwitchListTile.adaptive(
                  value: switchState["activityRecognition"] == true,
                  onChanged: (switchState["activityRecognition"] != null)
                      ? null
                      : (value) =>
                          _requestActivityRecognitionPermissions(value),
                  title: const Text(
                    'Activity Recognition',
                  ),
                  subtitle: const Text(
                    'Conserve battery by only connecting to WiFi when walking, standing, etc.',
                  ),
                  tileColor: Theme.of(context).colorScheme.surface,
                  activeColor: Theme.of(context).colorScheme.primary,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
