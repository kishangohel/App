import 'dart:io';

import 'package:verifi/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('wallet_logos assets test', () {
    expect(File(WalletLogos.cryptoCom).existsSync(), true);
    expect(File(WalletLogos.ledgerLive).existsSync(), true);
    expect(File(WalletLogos.metamask).existsSync(), true);
  });
}
