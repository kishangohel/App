import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/common/widgets/verifi_dialog.dart';
import 'package:verifi/src/features/access_points/application/report_access_point_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_reason_model.dart';

class ReportAccessPointDialog extends ConsumerStatefulWidget {
  final AccessPoint accessPoint;

  const ReportAccessPointDialog({
    Key? key,
    required this.accessPoint,
  }) : super(key: key);

  /// Display the report dialog and then show a thank you message if the user
  /// sends a report. This is useful when showing the dialog from a bottom
  /// sheet as showing a SnackBar to thank the user is complicated because
  /// the SnackBar is hidden by the bottom sheet.
  static Future showWithThankYouMessage(
    BuildContext context, {
    required AccessPoint accessPoint,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ReportAccessPointDialog(accessPoint: accessPoint),
    ).then((result) {
      if (result == true) {
        return showDialog(
          context: context,
          builder: (context) => _ReportAccessThankYouDialog(),
        );
      } else {
        return null;
      }
    });
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ReportAccessPointDialogState();
}

class ReportAccessPointDialogState
    extends ConsumerState<ReportAccessPointDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AccessPointReportReason? _reportReason;
  String? _description;

  final _descriptionFocusNode = FocusNode(debugLabel: 'descriptionFocusNode');

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AccessPointReport?>>(
        reportAccessPointControllerProvider, (prev, next) {
      if (prev?.valueOrNull == null && next.valueOrNull != null) {
        final goRouter = GoRouter.of(context);
        if (goRouter.canPop()) goRouter.pop(true);
      }
    });

    final reportNetworkState = ref.watch(reportAccessPointControllerProvider);
    final bool loading = reportNetworkState.isLoading;

    return VerifiDialog(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(),
            _reasonField(loading: loading),
            _descriptionField(loading: loading),
            if (reportNetworkState.hasError)
              _errorSection(reportNetworkState.error!),
            _submitButton(loading: loading),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        "Report Network",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _reasonField({required bool loading}) {
    return DropdownButtonFormField<AccessPointReportReason>(
      validator: (value) {
        if (value == null) return 'Required';
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 8.0,
        ),
        labelText: 'Reason',
      ),
      items: const [
        DropdownMenuItem(
          value: AccessPointReportReason.incorrectSsid,
          child: Text('Incorrect ssid (network name)'),
        ),
        DropdownMenuItem(
          value: AccessPointReportReason.missingPassword,
          child: Text('Missing password'),
        ),
        DropdownMenuItem(
          value: AccessPointReportReason.incorrectPassword,
          child: Text('Incorrect password'),
        ),
        DropdownMenuItem(
          value: AccessPointReportReason.other,
          child: Text('Other'),
        ),
      ],
      onChanged: loading
          ? null
          : (reason) {
              setState(() {
                _reportReason = reason;
              });
              if (reason == AccessPointReportReason.other) {
                _requestFocus(_descriptionFocusNode);
              }
            },
    );
  }

  Widget _descriptionField({required bool loading}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
        maxLines: 4,
        focusNode: _descriptionFocusNode,
        enabled: !(loading || _reportReason == null),
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 8.0,
          ),
          labelText: 'Description',
        ),
        validator: (value) {
          if (_reportReason == AccessPointReportReason.other &&
              (value == null || value.trim().isEmpty)) {
            return 'Description is required when reason is "Other"';
          }
          return null;
        },
        onChanged: (newDescription) {
          final withoutBlanks = newDescription.trim();
          setState(() {
            _description = withoutBlanks.isEmpty ? null : withoutBlanks;
          });
        },
      ),
    );
  }

  Widget _errorSection(Object error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        "An unexpected error occurred: ${error.toString()}",
      ),
    );
  }

  Widget _submitButton({required bool loading}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 30,
            padding: const EdgeInsets.only(right: 16.0),
            child: loading ? const CircularProgressIndicator() : null,
          ),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    _formKey.currentState!.save();
                    if (!_formKey.currentState!.validate()) return;

                    final accessPointReport = AccessPointReport(
                      accessPointId: widget.accessPoint.id,
                      reason: _reportReason!,
                      description: _description,
                    );
                    ref
                        .read(reportAccessPointControllerProvider.notifier)
                        .reportAccessPoint(accessPointReport);
                  },
            child: const Text("Submit"),
          ),
          const SizedBox(
            width: 46,
            height: 30,
          ),
        ],
      ),
    );
  }

  // Request focus in the next frame, this allows the target widget
  // to become enabled if necessary before we focus it.
  void _requestFocus(FocusNode focusNode) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }
}

class _ReportAccessThankYouDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title(context),
        _message(context),
        _closeButton(context),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        "Report Network",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _message(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Text(
        'Your report has been received, thank you.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          GoRouter.of(context).pop();
        },
        child: const Text(
          "Close",
        ),
      ),
    );
  }
}
