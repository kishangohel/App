import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

void main() {
  group(TierIdentifier, () {
    test(
      """
      Given a String that is not a valid TierIdentifier
      When we attempt to encoe it
      Then it throws an Exception
      """,
      () {
        expect(() => TierIdentifier.encode('invalid'), throwsException);
      },
    );

    test(
      """
      Given a TierIdentifier
      When we attempt to decode it
      Then it returns the correct string
      """,
      () {
        expect(TierIdentifier.decode(TierIdentifier.bronze), 'Bronze');
        expect(TierIdentifier.decode(TierIdentifier.silver), 'Silver');
        expect(TierIdentifier.decode(TierIdentifier.gold), 'Gold');
      },
    );

    test(
      """
      Given a String that is a valid TierIdentifier
      When we attempt to encode it
      Then it returns the correct TierIdentifier
      """,
      () {
        expect(TierIdentifier.encode('Bronze'), TierIdentifier.bronze);
        expect(TierIdentifier.encode('Silver'), TierIdentifier.silver);
        expect(TierIdentifier.encode('Gold'), TierIdentifier.gold);
      },
    );
  });
}
