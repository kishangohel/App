import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';

import '../helper.dart';

void main() {
  group(AccessPointReport, () {
    group('toFirestoreData', () {
      test(
        """
        Given an AccessPointReport object,
        When toFirestoreData is called,
        Then a valid Map is returned.
        """,
        () {
          final data = fakeAccessPointReport.toFirestoreData();
          expect(data, fakeAccessPointReportData);
        },
      );
    });

    group('fromFirestoreData', () {
      test(
        """
        Given an Firestore object representing an AccessPointReport,
        When fromFirestoreData is called,
        Then a valid AccessPointReport is returned.
        """,
        () {
          final data =
              AccessPointReport.fromFirestoreData(fakeAccessPointReportData);
          expect(data, fakeAccessPointReport);
        },
      );

      test(
        """
        Given an Firestore object representing an AccessPointReport
        with an invalid reason,
        When fromFirestoreData is called,
        Then an Exception is thrown. 
        """,
        () {
          expect(
            () => AccessPointReport.fromFirestoreData(
              fakeAccessPointReportDataInvalidReason,
            ),
            throwsException,
          );
        },
      );
    });
  });
}
