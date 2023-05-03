import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/access_points/application/access_point_connection_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/presentation/connect_button_visibility_controller.dart';
import 'package:verifi/src/features/access_points/presentation/report_access_point_dialog.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class AccessPointInfoSheet extends ConsumerWidget {
  final AccessPoint accessPoint;

  const AccessPointInfoSheet(this.accessPoint);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String?>>(
      accessPointConnectionControllerProvider,
      (previous, next) {
        if (previous?.valueOrNull == null && next.valueOrNull != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            _connectSnackBar(context, next.value!),
          );
          context.pop();
        } else if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            _connectSnackBar(
              context,
              next.error!.toString(),
            ),
          );
          context.pop();
        }
      },
    );

    final connectionState = ref.watch(accessPointConnectionControllerProvider);
    final contributorProfile =
        ref.watch(userProfileFamily(accessPoint.submittedBy));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameAndAddress(context),
          _networkName(),
          _networkPassword(),
          _verifiedStatus(),
          _contributor(contributorProfile),
          _connectButton(
            context,
            ref,
            connectionState: connectionState,
          ),
        ],
      ),
    );
  }

  Widget _nameAndAddress(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              accessPoint.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              accessPoint.address,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    ReportAccessPointDialog(accessPoint: accessPoint),
              );
            },
            icon: const Icon(
              Icons.report,
              size: 26,
              color: Color.fromRGBO(196, 175, 175, 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _networkName() {
    return _detailsRow(
      leading: const Icon(Icons.wifi),
      label: Text(accessPoint.ssid),
    );
  }

  Widget _networkPassword() {
    return _detailsRow(
      leading: accessPoint.password == null || accessPoint.password!.isEmpty
          ? const Icon(Icons.lock_open)
          : const Icon(Icons.lock_outlined),
      label: Text(
        (accessPoint.password == null || accessPoint.password == "")
            ? "Open"
            : "\u2022" * accessPoint.password!.length,
      ),
    );
  }

  Widget _verifiedStatus() {
    return _detailsRow(
      leading: accessPoint.isVerified
          ? const Icon(Icons.check)
          : const Icon(Icons.question_mark),
      label: Text(accessPoint.verifiedStatusLabel),
    );
  }

  Widget _contributor(AsyncValue<UserProfile?> profile) {
    const padding = EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0);

    if (profile.isLoading) {
      return _detailsRow(
        leading: const VShimmerWidget(
          width: 24,
          height: 24,
          margin: EdgeInsets.zero,
        ),
        label: const VShimmerWidget(
          width: 120,
          height: 24,
          margin: EdgeInsets.zero,
        ),
        padding: padding,
      );
    }
    final displayName = profile.valueOrNull?.displayName;

    return Visibility(
      visible: displayName != null,
      child: _detailsRow(
        leading: RandomAvatar(
          displayName ?? "Unknown",
          trBackground: true,
          width: 24,
          height: 24,
        ),
        label: Text(displayName ?? "Unknown"),
        padding: padding,
      ),
    );
  }

  Widget _detailsRow({
    required Widget leading,
    required Widget label,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 8.0),
            child: leading,
          ),
          label,
        ],
      ),
    );
  }

  Widget _connectButton(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<String?> connectionState,
  }) {
    // Only allow connecting if close enough and not original Contributor
    return Visibility(
      visible: ref
          .watch(connectButtonVisibilityControllerProvider.call(accessPoint))
          .when<bool>(
            data: (data) => data,
            error: (_, __) => false,
            loading: () => false,
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 8.0,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
          ),
          onPressed: connectionState.isLoading
              ? null
              : () {
                  ref
                      .read(accessPointConnectionControllerProvider.notifier)
                      .connectOrVerify(accessPoint);
                },
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (connectionState.isLoading)
              Container(
                padding: const EdgeInsets.only(right: 8),
                width: 29,
                height: 22,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            accessPoint.isVerified
                ? const Text("Connect")
                : const Text("Validate"),
            if (connectionState.isLoading) const SizedBox(width: 29),
          ]),
        ),
      ),
    );
  }

  /// Shows the result of the connection attempt.
  SnackBar _connectSnackBar(BuildContext context, String result) {
    return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      content: Text(
        result,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
