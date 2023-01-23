import 'package:auto_size_text/auto_size_text.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/common/providers/wifi_connected_stream_provider.dart';
import 'package:verifi/src/common/widgets/verifi_dialog.dart';
import 'package:verifi/src/features/access_points/data/radar_search_repository.dart';
import 'package:verifi/src/features/access_points/domain/radar_address_model.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';

import '../application/add_access_point_controller.dart';
import '../domain/new_access_point_model.dart';

class AddAccessPointDialog extends ConsumerStatefulWidget {
  final String ssid;

  const AddAccessPointDialog({
    Key? key,
    required this.ssid,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddAccessPointDialogState();
}

class AddAccessPointDialogState extends ConsumerState<AddAccessPointDialog> {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  final placeController = TextEditingController();
  RadarAddress? selectedRadarAddress;
  final _passwordFocusNode = FocusNode(debugLabel: 'passwordFocusNode');
  final _radarAddressFocusNode = FocusNode(debugLabel: 'radarAddressFocusNode');
  bool _isPasswordRequired = false;

  @override
  void initState() {
    super.initState();
    // Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      String ssid = widget.ssid;
      // Remove outer quotes if present
      if (widget.ssid.startsWith('"') &&
          widget.ssid.endsWith('"') &&
          widget.ssid.length > 1) {
        ssid = widget.ssid.substring(
          1,
          widget.ssid.length - 1,
        );
      }
      ssidController.text = ssid;
    }
    // iOS
    else {
      ssidController.text = widget.ssid;
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _radarAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dismiss dialog and show snackbar when we are no longer connected to WiFi
    ref.listen<AsyncValue<bool>>(
      isConnectedToWiFiProvider,
      (previous, next) {
        if (previous?.valueOrNull != false && next.valueOrNull == false) {
          final goRouter = GoRouter.of(context);
          if (goRouter.canPop()) {
            goRouter
                .pop(const CreateAccessPointDialogResult.wifiDisconnected());
          }
        }
      },
    );
    ref.listen<AsyncValue<NewAccessPoint?>>(
      addAccessPointControllerProvider,
      (previous, next) {
        if (next.valueOrNull != null) {
          final goRouter = GoRouter.of(context);
          if (goRouter.canPop()) {
            goRouter.pop(CreateAccessPointDialogResult.success(next.value!));
          }
        } else if ((previous == null || previous.isLoading) &&
            next.hasValue &&
            next.value == null) {
          _requestFocus(_radarAddressFocusNode);
        }
      },
    );

    final addNetworkState = ref.watch(addAccessPointControllerProvider);
    final bool loading = addNetworkState.isLoading;

    return VerifiDialog(
      child: Column(
        children: [
          _title(),
          _ssidTextField(),
          _passwordRow(loading: loading),
          _radarSearchFormField(loading: loading),
          if (addNetworkState.hasError) _errorSection(addNetworkState.error!),
          _submitButton(loading: loading),
        ],
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        "Add Network",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _ssidTextField() {
    return TextField(
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
        labelText: 'SSID',
      ),
      enabled: false,
      controller: ssidController,
    );
  }

  Widget _passwordRow({required bool loading}) {
    return Row(
      children: [
        // Password text field
        Expanded(
          child: TextFormField(
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
              labelText: 'Password',
            ),
            enabled: _isPasswordRequired,
            focusNode: _passwordFocusNode,
            controller: passwordController,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 16.0,
            left: 16.0,
          ),
          child: Column(
            children: [
              AutoSizeText(
                "Password\nrequired?",
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Switch(
                value: _isPasswordRequired,
                onChanged: loading
                    ? null
                    : (value) {
                        if (value == false) {
                          passwordController.clear();
                        }
                        setState(() {
                          _isPasswordRequired = value;
                        });

                        if (_isPasswordRequired) {
                          _requestFocus(_passwordFocusNode);
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radarSearchFormField({required bool loading}) {
    return TypeAheadFormField<RadarAddress>(
      enabled: !loading,
      debounceDuration: const Duration(milliseconds: 500),
      onSuggestionSelected: (radarAddress) async {
        placeController.text = radarAddress.name;
        setState(() {
          selectedRadarAddress = radarAddress;
        });
      },
      itemBuilder: (context, place) {
        return ListTile(
          title: AutoSizeText(
            place.name,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: AutoSizeText(
            place.address,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      errorBuilder: (context, error) {
        return ListTile(
          title: const Text("Error"),
          subtitle: Text(error.toString()),
        );
      },
      suggestionsCallback: (query) async {
        if (query == '') {
          return [];
        }
        final currentLocation =
            ref.read(locationRepositoryProvider).currentLocation;
        if (currentLocation != null) {
          return await ref
              .read(radarSearchRepositoryProvider)
              .searchNearbyPlaces(currentLocation, query);
        } else {
          return [];
        }
      },
      textFieldConfiguration: TextFieldConfiguration(
        focusNode: _radarAddressFocusNode,
        enabled: !loading,
        autofocus: true,
        controller: placeController,
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
          labelText: 'Location',
        ),
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
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(top: 16),
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
            onPressed: loading || selectedRadarAddress == null
                ? null
                : () async {
                    final newAccessPoint = NewAccessPoint(
                      ssid: ssidController.text,
                      password:
                          _isPasswordRequired ? passwordController.text : null,
                      radarAddress: selectedRadarAddress!,
                    );
                    ref
                        .read(addAccessPointControllerProvider.notifier)
                        .addAccessPoint(newAccessPoint);
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

class CreateAccessPointDialogResult extends Equatable {
  final NewAccessPoint? _newAccessPoint;

  const CreateAccessPointDialogResult.success(this._newAccessPoint);

  const CreateAccessPointDialogResult.wifiDisconnected()
      : _newAccessPoint = null;

  void handle(Function(NewAccessPoint) success, Function wifiDisconnected) {
    if (_newAccessPoint == null) {
      wifiDisconnected();
    } else {
      success(_newAccessPoint!);
    }
  }

  @override
  List<Object?> get props => [_newAccessPoint];
}
