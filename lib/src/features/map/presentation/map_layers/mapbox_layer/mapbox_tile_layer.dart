import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../flutter_map/map_flutter_map.dart';

class MapboxTileLayer extends StatefulWidget {
  static const _user = "bifrostyyy";
  static const _tileSize = "256"; // 256 or 512
  // TODO: Replace with more restricted access token via dart-define
  static const _accessToken =
      "pk.eyJ1IjoiYmlmcm9zdHl5eSIsImEiOiJjbGIweHR0dGgwenVlM3dyejdheDc1aHBlIn0.rcH_qr3n01hJXmMsqaK-Rw";
  static const _userAgentPackageName = 'world.verifi.app';
  static const _tileSetDarkId = 'clb0zq1n6000w14rzcw97r4kf'; // TODO dark style
  static const _tileSetLightId = 'clb0zq1n6000w14rzcw97r4kf';

  @override
  State<MapboxTileLayer> createState() => _MapboxTileLayerState();
}

class _MapboxTileLayerState extends State<MapboxTileLayer>
    with WidgetsBindingObserver {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    // Used for dynamically changing map style for light/dark mode
    WidgetsBinding.instance.addObserver(this);
    _setMapStyle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      maxZoom: MapFlutterMap.maxZoom,
      tileProvider: CachedNetworkTileProvider(),
      urlTemplate:
          "https://api.mapbox.com/styles/v1/{user}/{tile_set_id}/tiles/{tile_size}/{z}/{x}/{y}@2x?access_token={access_token}",
      additionalOptions: {
        "user": MapboxTileLayer._user,
        "access_token": MapboxTileLayer._accessToken,
        "tile_set_id": _darkMode
            ? MapboxTileLayer._tileSetDarkId
            : MapboxTileLayer._tileSetLightId,
        "tile_size": MapboxTileLayer._tileSize,
      },
      userAgentPackageName: MapboxTileLayer._userAgentPackageName,
    );
  }

  Future _setMapStyle() async {
    final brightness = WidgetsBinding.instance.window.platformBrightness;

    setState(() {
      _darkMode = brightness == Brightness.dark;
    });
  }
}

class CachedNetworkTileProvider extends TileProvider {
  CachedNetworkTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }
}
