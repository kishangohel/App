import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/application/report_access_point_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_reason_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/access_points/presentation/report_access_point_dialog.dart';
import '../../../../test_helper/register_fallbacks.dart';
import '../../../../test_helper/riverpod_test_helper.dart';
import 'report_access_point_controller_stub.dart';

/// A simple widget which loads the dialog.
class _TestPage extends StatefulWidget {
  final AccessPoint accessPoint;

  const _TestPage(this.accessPoint);

  @override
  State<_TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<_TestPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ReportAccessPointDialog.showWithThankYouMessage(
        context,
        accessPoint: widget.accessPoint,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  late ReportAccessPointControllerStub reportAccessPointControllerStub;
  final accessPoint = AccessPoint(
    id: 'testAccessPointId',
    ssid: 'testAccessPointSsid',
    location: LatLng(1.0, 2.0),
    submittedBy: 'testUserId',
    verifiedStatus: VerifiedStatus.unverified,
  );

  void createProviderMocks() {
    reportAccessPointControllerStub = ReportAccessPointControllerStub();
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) async {
    final container = await makeWidgetWithRiverpod(
      tester,
      goRouter: GoRouter(
        routes: [
          GoRoute(
            path: '/testPage',
            name: '/testPage',
            builder: (context, state) => _TestPage(accessPoint),
          ),
        ],
        initialLocation: '/testPage',
      ),
      overrides: [
        reportAccessPointControllerProvider
            .overrideWith(() => reportAccessPointControllerStub),
      ],
    );
    // Wait for the dialog to show.
    await tester.pump();

    return container;
  }

  Finder reasonFieldFinder() =>
      find.byType(DropdownButtonFormField<AccessPointReportReason>);
  Finder descriptionFieldFinder() => find.byType(TextFormField);
  Finder errorSectionFinder() => find.byWidgetPredicate((widget) =>
      widget is Text &&
      widget.data?.startsWith("An unexpected error occurred:") == true);
  Finder submitButtonFinder() => find.byType(ElevatedButton);

  DropdownButtonFormField<AccessPointReportReason> reasonField(
          WidgetTester tester) =>
      tester.widget(reasonFieldFinder());

  TextFormField descriptionField(WidgetTester tester) =>
      tester.widget(descriptionFieldFinder());

  Text errorSection(WidgetTester tester) => tester.widget(errorSectionFinder());
  ElevatedButton submitButton(WidgetTester tester) =>
      tester.widget(submitButtonFinder());

  FocusNode focusedNode(WidgetTester tester) =>
      FocusScope.of(tester.element(find.byType(ReportAccessPointDialog)))
          .focusedChild!;

  group(ReportAccessPointDialog, () {
    setUpAll(() {
      registerFallbacks();
    });

    testWidgets('loading state', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      expect(reasonField(tester).onChanged, isNull);
      expect(descriptionField(tester).enabled, isFalse);
      expect(errorSectionFinder(), findsNothing);
      expect(submitButton(tester).enabled, isFalse);
    });

    testWidgets('loaded', (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      expect(reasonField(tester).onChanged, isNotNull);
      expect(descriptionField(tester).enabled, isFalse);
      expect(errorSectionFinder(), findsNothing);
      expect(submitButton(tester).enabled, isTrue);
    });

    testWidgets('choose description', (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(reasonFieldFinder());
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the menu animation
      await tester.tap(find.text("Missing password").last);
      await tester.pump();

      expect(descriptionField(tester).enabled, isTrue);
      expect(errorSectionFinder(), findsNothing);
      expect(submitButton(tester).enabled, isTrue);
    });

    testWidgets('choose reason that does not require description, submit',
        (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(reasonFieldFinder());
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the menu animation
      await tester.tap(find.text("Missing password").last);
      await tester.pump();

      await tester.tap(submitButtonFinder());
      expect(reportAccessPointControllerStub.accessPointReports, [
        AccessPointReport(
          accessPoint: accessPoint,
          reason: AccessPointReportReason.missingPassword,
        )
      ]);
    });

    testWidgets('choose "other" reason, description field is selected',
        (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(reasonFieldFinder());
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the menu animation
      await tester.tap(find.text("Other").last);
      await tester.pump();

      expect(focusedNode(tester).debugLabel, equals('descriptionFocusNode'));
      expect(descriptionField(tester).enabled, isTrue);
      expect(errorSectionFinder(), findsNothing);
      expect(submitButton(tester).enabled, isTrue);
    });

    testWidgets('submit with "other" reason without description',
        (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(reasonFieldFinder());
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the menu animation
      await tester.tap(find.text("Other").last);
      await tester.pump();

      await tester.tap(submitButtonFinder());
      await tester.pump();
      expect(find.text('Description is required when reason is "Other"'),
          findsOneWidget);
    });

    testWidgets('submit with "other" reason with description', (tester) async {
      createProviderMocks();
      reportAccessPointControllerStub.setInitialValue(null);
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(reasonFieldFinder());
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the menu animation
      await tester.tap(find.text("Other").last);
      await tester.pump();

      await tester.enterText(descriptionFieldFinder(), "A test description");

      await tester.tap(submitButtonFinder());
      expect(reportAccessPointControllerStub.accessPointReports, [
        AccessPointReport(
            accessPoint: accessPoint,
            reason: AccessPointReportReason.other,
            description: 'A test description')
      ]);
    });

    testWidgets('error', (tester) async {
      createProviderMocks();
      final container = await makeWidget(tester);
      await tester.pump();
      reportAccessPointControllerStub
          .triggerUpdate(AsyncError("A test error", StackTrace.current));

      await container.pump();
      await tester.pump();

      expect(
        errorSection(tester).data,
        'An unexpected error occurred: A test error',
      );
    });

    testWidgets('successful submit', (tester) async {
      createProviderMocks();
      final container = await makeWidget(tester);
      await tester.pump();

      reportAccessPointControllerStub.triggerUpdate(
        AsyncData(
          AccessPointReport(
            accessPoint: accessPoint,
            reason: AccessPointReportReason.incorrectSsid,
          ),
        ),
      );
      await container.pump();
      await tester.pump();
      expect(
        find.text('Your report has been received, thank you.'),
        findsOneWidget,
      );
    });
  });
}
