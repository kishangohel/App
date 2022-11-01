import 'dart:async';

import 'package:auto_connect/auto_connect.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:verifi/models/place.dart';

class ValidateNetworkPage extends StatefulWidget {
  final PageController controller;
  final String? ssid;
  final String? password;
  final Place? place;

  const ValidateNetworkPage({
    required this.controller,
    required this.ssid,
    required this.password,
    required this.place,
  });

  @override
  State<StatefulWidget> createState() => _ValidateNetworkPageState();
}

class _ValidateNetworkPageState extends State<ValidateNetworkPage> {
  bool _submitted = false;
  final validated = Completer<String>();
  @override
  Widget build(BuildContext context) {
    assert(widget.ssid != null && widget.place != null);
    return Column(
      children: [
        _validateNetworkTitle(),
        Expanded(
          child: _validationBody(),
        ),
        _validationFooter(),
      ],
    );
  }

  Widget _validationBody() {
    return Column(
      children: [
        Flexible(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 8.0, bottom: 48.0),
                child: AutoSizeText(
                  'Please review the information below to ensure it is accurate',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: AutoSizeText(
                          'SSID: ',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: AutoSizeText(
                          widget.ssid ?? '',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: AutoSizeText(
                          "Password: ",
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: AutoSizeText(
                          widget.password ?? 'N/A',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: AutoSizeText(
                          "Location: ",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: AutoSizeText(
                          widget.place?.name ?? '',
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 48.0),
                child: Text(
                  'If everything looks good, click Submit below to add this '
                  'network to the VeriNet',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Center(
                  child: Visibility(
                    visible: _submitted,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            'Validating network...',
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            height: 80,
                            width: 80,
                            child: FutureBuilder(
                              future: validated.future,
                              builder:
                                  (context, AsyncSnapshot<String?> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Icon(
                                    (snapshot.data == "Success")
                                        ? Icons.check
                                        : Icons.close,
                                    size: 60,
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _validateNetworkTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        "Validate Network",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _validationFooter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(
            height: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _navigationButtons(),
      ],
    );
  }

  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // Prevent back navigation if currently submitting
            if (_submitted) return;
            widget.controller.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            );
          },
          child: Text(
            "Back",
            style: Theme.of(context).textTheme.button,
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_submitted) return;
            setState(() {
              _submitted = true;
            });
            final result = await AutoConnect.verifyAccessPoint(
              wifi: WiFi(
                ssid: widget.ssid ?? "",
                password: widget.password ?? "",
              ),
            );
            debugPrint("Verify AP result: $result");
            validated.complete(result);
            if (result != "Success") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result),
                ),
              );
            }
            Future.delayed(
              const Duration(milliseconds: 1500),
              () => Navigator.of(context).pop(),
            );
          },
          child: Text(
            "Submit",
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ],
    );
  }
}
