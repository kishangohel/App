import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_location_permissions_controller.dart';

class LocationPermissionDialog extends ConsumerStatefulWidget {
  static Future show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => LocationPermissionDialog(),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationPermissionDialogState();
}

class LocationPermissionDialogState
    extends ConsumerState<LocationPermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location permission'),
      content: const Text('Please allow location access to use the map'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await ref
                .read(mapLocationPermissionsControllerProvider.notifier)
                .requestPermission();
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Allow'),
        ),
      ],
    );
  }
}
