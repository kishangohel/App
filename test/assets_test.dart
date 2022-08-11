import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/resources/resources.dart';

void main() {
  test('assets assets test', () {
    expect(File(Assets.vfAndroid).existsSync(), true);
    expect(File(Assets.vfIos).existsSync(), true);
    expect(File(Assets.people01).existsSync(), true);
    expect(File(Assets.people02).existsSync(), true);
    expect(File(Assets.people03).existsSync(), true);
    expect(File(Assets.people04).existsSync(), true);
    expect(File(Assets.people05).existsSync(), true);
    expect(File(Assets.people06).existsSync(), true);
    expect(File(Assets.people07).existsSync(), true);
    expect(File(Assets.people08).existsSync(), true);
    expect(File(Assets.people09).existsSync(), true);
    expect(File(Assets.people10).existsSync(), true);
    expect(File(Assets.people11).existsSync(), true);
    expect(File(Assets.people12).existsSync(), true);
    expect(File(Assets.people13).existsSync(), true);
    expect(File(Assets.people14).existsSync(), true);
    expect(File(Assets.people15).existsSync(), true);
    expect(File(Assets.people16).existsSync(), true);
    expect(File(Assets.people17).existsSync(), true);
    expect(File(Assets.people18).existsSync(), true);
    expect(File(Assets.people19).existsSync(), true);
    expect(File(Assets.people20).existsSync(), true);
    expect(File(Assets.people21).existsSync(), true);
    expect(File(Assets.people22).existsSync(), true);
    expect(File(Assets.people23).existsSync(), true);
    expect(File(Assets.people24).existsSync(), true);
    expect(File(Assets.facebookNew).existsSync(), true);
    expect(File(Assets.googleLight).existsSync(), true);
    expect(File(Assets.cryptoCom).existsSync(), true);
    expect(File(Assets.ledgerLive).existsSync(), true);
    expect(File(Assets.metamask).existsSync(), true);
  });
}
