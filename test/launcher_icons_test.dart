import 'dart:io';

import 'package:verifi/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('launcher_icons assets test', () {
    expect(File(LauncherIcons.vfAndroid).existsSync(), true);
    expect(File(LauncherIcons.vfIos).existsSync(), true);
  });
}
