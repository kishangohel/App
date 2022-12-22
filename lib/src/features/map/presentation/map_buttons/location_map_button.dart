import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/location_permission_dialog.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_location_permissions_controller.dart';

class LocationMapButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: _onPressed(context, ref),
      child: Icon(
        Icons.my_location,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  VoidCallback? _onPressed(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationStreamProvider).valueOrNull;

    return ref.watch(mapLocationPermissionsControllerProvider).when(
      data: (data) {
        if (data.isDeniedPermanently) {
          return _onPressedWhenPermanentlyDenied(context, ref);
        } else if (data.isDenied) {
          return _onPressedWhenDenied(context, ref);
        } else {
          return _onPressedWhenAllowed(ref, location);
        }
      },
      error: (error, stackTrace) {
        return null;
      },
      loading: () {
        return null;
      },
    );
  }

  VoidCallback? _onPressedWhenAllowed(WidgetRef ref, LatLng? location) {
    if (location == null) {
      return null;
    } else {
      return () {
        ref.read(mapControllerProvider).move(location, 18);
      };
    }
  }

  VoidCallback _onPressedWhenDenied(BuildContext context, WidgetRef ref) {
    return () => LocationPermissionDialog.show(context);
  }

  VoidCallback? _onPressedWhenPermanentlyDenied(
      BuildContext context, WidgetRef ref) {
    return () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied, please enable in device settings.",
          ),
        ),
      );
    };
  }
}
