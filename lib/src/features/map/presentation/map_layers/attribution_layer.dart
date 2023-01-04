import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// A layer which fulfills Mapbox and OpenStreetMap's attribution requirements:
/// https://docs.mapbox.com/help/getting-started/attribution/
class AttributionLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/mapbox.png',
                  width: 65,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _linkTo(
                  'Improve this map',
                  'https://www.mapbox.com/map-feedback/',
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('© '),
                    _linkTo(
                      'Mapbox',
                      'https://www.mapbox.com/about/maps/',
                    ),
                    const Text(' © '),
                    _linkTo(
                      'OpenStreetMap',
                      'http://www.openstreetmap.org/about/',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _linkTo(String name, String url) {
    return GestureDetector(
      onTap: () {
        launchUrlString(url);
      },
      child: Text(
        name,
        textAlign: TextAlign.end,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
