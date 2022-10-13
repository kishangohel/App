import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/blocs/places/places_cubit.dart';
import 'package:verifi/models/place.dart';

class AddNetworkPage extends StatelessWidget {
  final String? wifiName;
  final String? placeName;
  const AddNetworkPage({this.wifiName, this.placeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 4.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          AddNetworkTitle(),
          SSIDRow(wifiName),
          PasswordRow(),
          Expanded(
            child: PlaceRow(placeName),
          ),
          SubmitNetworkButton(),
        ],
      ),
    );
  }
}

class AddNetworkTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        "Add Network",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class SSIDRow extends StatefulWidget {
  final String? wifiName;

  const SSIDRow(this.wifiName);

  @override
  State<StatefulWidget> createState() => _SSIDRowState();
}

class _SSIDRowState extends State<SSIDRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
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
            initialValue: widget.wifiName?.replaceAll('"', ''),
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
              builder: (context) => _alertDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _alertDialog() {
    return AlertDialog(
      title: Text(
        "Why can't I edit this?",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        "You may only submit the currently connected WiFi network to VeriNet.",
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
}

class PasswordRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PasswordRowState();
}

class _PasswordRowState extends State<PasswordRow> {
  final _controller = TextEditingController();
  bool _isPasswordRequired = true;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
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
                  value: _isPasswordRequired,
                  onChanged: (value) {
                    if (value == false) {
                      _controller.clear();
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
      controller: _controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: "Password",
        suffixIcon: (_controller.value.text.isNotEmpty)
            ? IconButton(
                icon: FaIcon(
                  _obscureText
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
                onPressed: () => setState(
                  () => _obscureText = !_obscureText,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 8.0,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      enabled: _isPasswordRequired,
      obscureText: _obscureText,
      onChanged: (text) => setState(() {}),
    );
  }
}

class PlaceRow extends StatefulWidget {
  final String? placeName;

  const PlaceRow(this.placeName);

  @override
  State<StatefulWidget> createState() => _PlaceRowState();
}

class _PlaceRowState extends State<PlaceRow> {
  final _controller = TextEditingController();
  bool isPlaceSelected = false;
  @override
  Widget build(BuildContext context) {
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
                      builder: (context) => _alertDialog(),
                    );
                  },
                ),
              ],
            ),
          )
        : _fixedPlaceTextField(widget.placeName!);
  }

  Widget _searchPlaceTypeAheadField() {
    return TypeAheadField<Place>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _controller,
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
      onSuggestionSelected: (place) {
        _controller.text = place.name;
        setState(() => isPlaceSelected = true);
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
      suggestionsCallback: (query) {
        if (query != "") {
          return context.read<PlacesCubit>().searchNearbyPlaces(
                query,
                context.read<LocationCubit>().state!,
              );
        }
        return <Place>[];
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
    );
  }

  Widget _alertDialog() {
    return AlertDialog(
      title: Text(
        "Why do only certain places show up?",
        style: Theme.of(context).textTheme.titleLarge,
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
}

class SubmitNetworkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {},
      child: Text(
        "Submit",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}
