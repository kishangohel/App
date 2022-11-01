import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:verifi/screens/map_screen/add_network/add_network_page_view.dart';

class AddNetworkFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.wifi),
      label: const Text("Add Network"),
      onPressed: () async {
        final wifiName = await NetworkInfo().getWifiName();
        // only open if user is currently connected to WiFi
        if (wifiName == null) {
          return;
        }
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          enableDrag: false,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: const SafeArea(
                child: AddNetworkPageView(),
              ),
            );
          },
        );
      },
    );
  }
}
