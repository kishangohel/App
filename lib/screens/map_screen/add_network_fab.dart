import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:verifi/screens/map_screen/add_network_page.dart';

class AddNetworkFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      icon: const Icon(Icons.wifi),
      label: const Text("Add Network"),
      elevation: 6.0,
      onPressed: () async {
        final wifiName = await NetworkInfo().getWifiName();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12.0),
          // ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: SafeArea(
                child: AddNetworkPage(wifiName: wifiName),
              ),
            );
          },
        );
      },
    );
  }
}
