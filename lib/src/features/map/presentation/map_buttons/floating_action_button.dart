import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:verifi/src/common/widgets/error_snackbar.dart';
import 'package:verifi/src/features/add_network/presentation/add_access_point_dialog.dart';
import 'package:verifi/src/features/map/application/map_service.dart';

class MapFloatingActionButton extends ConsumerStatefulWidget {
  const MapFloatingActionButton({Key? key}) : super(key: key);

  @override
  ConsumerState<MapFloatingActionButton> createState() =>
      _MapFloatingActionButtonState();
}

class _MapFloatingActionButtonState
    extends ConsumerState<MapFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final wifiName = await NetworkInfo().getWifiName();
        if (wifiName == null) {
          // show snackbar that we are not connected to WiFi
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar(
              context: context,
              message: 'You are not connected to WiFi.\nPlease connect to WiFi '
                  'before adding a network.',
            ),
          );
          return;
        }
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AddAccessPointDialog(ssid: wifiName);
          },
        ).then((result) {
          if (result is CreateAccessPointDialogResult) {
            result.handle((newAP) {
              ref
                  .read(mapServiceProvider)
                  .moveMapToCenter(newAP.radarAddress.location);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('New network added!'),
                  ),
                );
            }, (wifiDisconnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disconnected from WiFi'),
                ),
              );
            });
          }
        });
      },
      label: Row(
        children: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.wifi),
          ),
          Text('Add Network'),
        ],
      ),
    );
  }
}
