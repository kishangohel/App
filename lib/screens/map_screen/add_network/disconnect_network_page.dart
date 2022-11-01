import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DisconnectNetworkPage extends StatefulWidget {
  final PageController controller;
  final String? ssid;
  const DisconnectNetworkPage({
    required this.controller,
    required this.ssid,
  });

  @override
  State<StatefulWidget> createState() => _DisconnectNetworkPageState();
}

class _DisconnectNetworkPageState extends State<DisconnectNetworkPage> {
  bool _isDisconnected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _disconnectTitle(),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const AutoSizeText(
                  'In order to verify the accuracy of your contribution, we '
                  'need to connect to the network manually using the '
                  'information you provided on the previous screen.',
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ),
              const Image(
                image: AssetImage('assets/how_to_add_network_1.jpg'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const AutoSizeText(
                  'First, open your WiFi settings and tap the "Info" button '
                  'for the network.',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              const Image(
                image: AssetImage('assets/how_to_add_network_2.jpg'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const AutoSizeText(
                  'Then, select "Forget This Network".',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              const AutoSizeText(
                'VeriFi will automatically re-connect you to '
                'the network if the network information you provided '
                'is correct.',
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const AutoSizeText(
                  'Click "Refresh" when you\'ve completed this step.',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextButton(
                onPressed: () async {
                  var ssid = await NetworkInfo().getWifiName();
                  if (ssid != null &&
                      Platform.isAndroid &&
                      ssid.startsWith('"') &&
                      ssid.endsWith('"')) {
                    // Remove leading and trailing quotes
                    ssid = ssid.substring(1, ssid.length - 1);
                  }
                  if (ssid == null || ssid != widget.ssid) {
                    setState(() {
                      debugPrint("Disconnected");
                      _isDisconnected = true;
                    });
                  } else {
                    debugPrint("Still connected");
                  }
                },
                child: Text(
                  "Refresh",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                height: 2.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        _navigationButtons(),
      ],
    );
  }

  Widget _disconnectTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        "Disconnect from Network",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => widget.controller.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          ),
          child: Text(
            "Back",
            style: Theme.of(context).textTheme.button,
          ),
        ),
        Visibility(
          visible: _isDisconnected,
          child: TextButton(
            onPressed: () => widget.controller.animateToPage(
              2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            ),
            child: Text(
              "Next",
              style: Theme.of(context).textTheme.button,
            ),
          ),
        ),
      ],
    );
  }
}
