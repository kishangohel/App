import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/places_repository.dart';
import 'package:verifi/widgets/feed_screen/feed_card_details.dart';

class FeedCard extends StatelessWidget {
  final WifiDetails wifiDetails;
  final DetailsResult placeDetails;
  final LatLng myLocation;

  const FeedCard({
    required this.wifiDetails,
    required this.placeDetails,
    required this.myLocation,
  });

  @override
  Widget build(BuildContext context) {
    final List<Photo> photos = placeDetails.photos ?? [];
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        elevation: 4.0,
        child: Column(
          children: [
            Container(
              child: (photos.length > 0)
                  ? CachedNetworkImage(
                      imageUrl: _getPhotoReferenceUrl(
                        context,
                        photos[0].photoReference,
                      ),
                      height: 200,
                      fadeInDuration: Duration(seconds: 0),
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      alignment: Alignment.center,
                    )
                  : Container(),
            ),
            FeedCardDetails(
              name: placeDetails.name ?? "Unnamed",
              ssid: wifiDetails.ssid,
              distance: wifiDetails.distance,
              myLocation: myLocation,
              wifiLocation: wifiDetails.location,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(),
      ),
      onTap: () {},
    );
  }

  String _getPhotoReferenceUrl(BuildContext context, String? photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?photoreference=$photoReference&key=${context.read<PlacesRepository>().apiKey}&maxwidth=800";
  }
}
