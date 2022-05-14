import 'dart:io';

import 'package:verifi/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('assets assets test', () {
    expect(File(Assets.enterTheMetaverse).existsSync(), true);
    expect(File(Assets.wifiCity1).existsSync(), true);
    expect(File(Assets.wifiCity2).existsSync(), true);
    expect(File(Assets.wifiCity3).existsSync(), true);
    expect(File(Assets.wifiCity4).existsSync(), true);
    expect(File(Assets.wifiMarker).existsSync(), true);
  });
}
