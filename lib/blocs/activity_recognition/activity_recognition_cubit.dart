import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ActivityRecognitionCubit extends Cubit<int> {
  static const platform = MethodChannel("world.verifi.app/channel");

  ActivityRecognitionCubit() : super(0);

  static Future<void> requestActivityTransitionUpdates() async {
    final allowed = await _checkPermissions();
    if (allowed) {
      platform.invokeMethod(
        "startActivityRecognition",
        [
          PluginUtilities.getCallbackHandle(activityRecognitionCallback)!
              .toRawHandle()
        ],
      );
    }
  }

  static Future<bool> activityRecognitionCallback() async {
    return Future.value(true);
  }

  static Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      return Permission.activityRecognition.isGranted;
    } else if (Platform.isIOS) {
      return Permission.sensors.isGranted;
    }
    return false;
  }
}
