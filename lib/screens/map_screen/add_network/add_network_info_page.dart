import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/blocs/places/places_cubit.dart';
import 'package:verifi/models/place.dart';
import 'package:verifi/repositories/repositories.dart';

class AddNetworkInfoPage extends StatefulWidget {
  final PageController controller;
  final GlobalKey<FormState> formKey;
  final String? placeName;
  final Function(String) onSSIDUpdated;
  final Function(String) onPasswordUpdated;
  final Function(Place) onPlaceUpdated;

  const AddNetworkInfoPage({
    required this.controller,
    required this.formKey,
    this.placeName,
    required this.onSSIDUpdated,
    required this.onPasswordUpdated,
    required this.onPlaceUpdated,
  });

  @override
  State<StatefulWidget> createState() => _AddNetworkInfoPageState();
}

class _AddNetworkInfoPageState extends State<AddNetworkInfoPage> {
  String? _ssid;
  final _ssidController = TextEditingController();

  bool _isPlaceValid = false;

  final _passwordController = TextEditingController();
  bool _isPasswordRequired = false;
  bool _obscurePasswordText = true;

  final _placeController = TextEditingController();
  bool _isPlaceSelected = false;
  Place? _selectedPlace;

  void updateSSID(String ssid) {
    setState(() {
      _ssid = ssid;
      _ssidController.text = ssid;
      widget.onSSIDUpdated(ssid);
    });
  }

  void updatePassword(String password) {
    widget.onPasswordUpdated(password);
  }

  void updatePlace(Place place) {
    widget.onPlaceUpdated(place);
  }

  @override
  void initState() {
    super.initState();
    _isPlaceValid = widget.placeName != null;
    getSsid();
  }

  Future<void> getSsid() async {
    var ssid = await NetworkInfo().getWifiName();
    if (ssid != null) {
      if (Platform.isAndroid && ssid.startsWith('"') && ssid.endsWith('"')) {
        // Remove leading and trailing quotes
        ssid = ssid.substring(1, ssid.length - 1);
      }
      updateSSID(ssid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _addNetworkTitle(),
          _ssidRow(_ssid),
          _passwordRow(),
          Expanded(
            child: _placeRow(),
          ),
          _navigationButtons(),
        ],
      ),
    );
  }

  Widget _ssidRow(String? ssid) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _ssidController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Network name",
              contentPadding: EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 8.0,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
            enabled: false,
            validator: (value) {
              if (value == null || value.isEmpty || value != ssid) {
                debugPrint("Invalid network");
                return "Invalid network";
              }
              return null;
            },
            onSaved: (value) {
              assert(value != null);
              updateSSID(value!);
            },
          ),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleQuestion,
            size: Theme.of(context).textTheme.titleMedium?.fontSize,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _ssidRowAlertDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _ssidRowAlertDialog() {
    return AlertDialog(
      title: Text(
        "Why can't I edit this?",
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(
        "You may only submit a WiFi network if your device is currently "
        "connected to that network.",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Close",
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ],
    );
  }

  Widget _passwordRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: _passwordTextFormField(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                AutoSizeText(
                  "Password\nrequired?",
                  maxLines: 2,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
                Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: _isPasswordRequired,
                  onChanged: (value) {
                    if (value == false) {
                      _passwordController.clear();
                    }
                    setState(() {
                      _isPasswordRequired = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordTextFormField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: "Password",
        suffixIcon: IconButton(
          icon: FaIcon(
            _obscurePasswordText
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
          ),
          onPressed: () => setState(
            () => _obscurePasswordText = !_obscurePasswordText,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 8.0,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      enabled: _isPasswordRequired,
      obscureText: _obscurePasswordText,
      onSaved: (value) {
        if (value != null) {
          updatePassword(value);
        }
      },
    );
  }

  Widget _placeRow() {
    return (widget.placeName == null)
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _searchPlaceTypeAheadField(),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.circleQuestion,
                    size: Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => _placeRowAlertDialog(),
                    );
                  },
                ),
              ],
            ),
          )
        : _fixedPlaceTextField(widget.placeName!);
  }

  Widget _searchPlaceTypeAheadField() {
    return TypeAheadFormField<Place>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _placeController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Location",
          contentPadding: EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 8.0,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onSuggestionSelected: (place) async {
        final placeDetails =
            await context.read<PlaceRepository>().getPlaceDetails(
                  place.placeId,
                  true,
                );
        place = place.copyWith(
          location: placeDetails.geometry!.location,
        );
        _placeController.text = place.name;
        setState(() {
          _isPlaceSelected = true;
          _selectedPlace = place;
        });
      },
      itemBuilder: (BuildContext context, Place place) {
        return ListTile(
          title: AutoSizeText(
            place.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
      errorBuilder: (context, error) {
        return Text(error.toString());
      },
      suggestionsCallback: (query) async {
        if (query != "") {
          await context.read<PlacesCubit>().searchNearbyPlaces(
                query,
                context.read<LocationCubit>().state!,
                100,
              );
          return context.read<PlacesCubit>().state;
        }
        return <Place>[];
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !_isPlaceSelected ||
            value != _selectedPlace?.name) {
          debugPrint("Invalid place");
          return "Invalid place";
        }
        _isPlaceValid = true;
        return null;
      },
      onSaved: (value) {
        assert(value != null && _selectedPlace != null);
        updatePlace(_selectedPlace!);
      },
    );
  }

  Widget _fixedPlaceTextField(String placeName) {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Location",
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      enabled: false,
      initialValue: widget.placeName,
      validator: (value) {
        if (value == null || value.isEmpty || value != placeName) {
          debugPrint("Invalid place");
          return "Invalid place";
        }
        return null;
      },
    );
  }

  Widget _placeRowAlertDialog() {
    return AlertDialog(
      title: Text(
        "Why do only certain places show up?",
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(
        "VeriNet only links WiFi access points to business esablishments "
        "(restaurants, coffee shops, etc.) that are within 200 meters of your "
        "location.\n\nIf the establishment is large, or the WiFi range extends "
        "beyond 200 meters, try moving closer to the location of the "
        "establishment identified by the VeriMap.",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Close",
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ],
    );
  }

  Widget _navigationButtons() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel", style: Theme.of(context).textTheme.button),
          ),
          Visibility(
            visible: _isPlaceValid,
            child: TextButton(
              onPressed: () async {
                final valid = widget.formKey.currentState!.validate();
                if (valid) {
                  widget.formKey.currentState!.save();
                  widget.controller.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear,
                  );
                }
              },
              child: Text(
                "Next",
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addNetworkTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        "Add Network",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
