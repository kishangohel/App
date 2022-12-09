import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/screens/map_screen/add_network/add_network_info_page.dart';
import 'package:verifi/screens/map_screen/add_network/disconnect_network_page.dart';
import 'package:verifi/screens/map_screen/add_network/validate_network_page.dart';

class AddNetworkPageView extends StatefulWidget {
  final Place? place;

  const AddNetworkPageView({this.place});

  @override
  State<StatefulWidget> createState() => _AddNetworkPageViewState();
}

class _AddNetworkPageViewState extends State<AddNetworkPageView> {
  String? ssid;
  String? password;
  Place? place;
  LatLng? location;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    place = widget.place;
  }

  @override
  Widget build(BuildContext context) {
    final _controller = PageController();
    final _pages = [
      AddNetworkInfoPage(
        controller: _controller,
        formKey: formKey,
        onSSIDUpdated: (ssid) {
          setState(() {
            this.ssid = ssid;
          });
        },
        onPlaceUpdated: (place) {
          setState(() {
            this.place = place;
          });
        },
        onPasswordUpdated: (password) {
          this.password = password;
        },
      ),
      DisconnectNetworkPage(
        controller: _controller,
        ssid: ssid,
      ),
      ValidateNetworkPage(
        controller: _controller,
        ssid: ssid,
        password: password,
        place: place,
      ),
    ];
    return Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Divider(
              thickness: 2,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, index) {
                return _pages[index];
              },
              itemCount: _pages.length,
              // disable scrolling
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}
