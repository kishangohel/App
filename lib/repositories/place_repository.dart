import 'package:flutter/foundation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:uuid/uuid.dart';

class PlaceRepository {
  final googlePlacesDbFilename = 'places.db';
  final store = stringMapStoreFactory.store();
  var sessionToken = const Uuid().v4();
  Database? googlePlacesDb;
  late GoogleMapsPlaces _googleMapsPlaces;

  PlaceRepository() {
    _googleMapsPlaces = GoogleMapsPlaces(
      apiKey: 'AIzaSyBgs18q9v_rpeJVM-dIg6ZKvajHxxglyN0',
    );
  }

  Future<void> initLocalDbs() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, googlePlacesDbFilename);
    googlePlacesDb = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> addPlaceDetailsToCache(PlaceDetails place) async {
    if (googlePlacesDb == null) {
      await initLocalDbs();
    }
    await store.record(place.placeId).put(
      googlePlacesDb!,
      {
        'formatted_address': place.formattedAddress,
        'icon': place.icon,
        'photos': place.photos
            .map((photo) => {
                  'photo_reference': photo.photoReference,
                  'width': photo.width,
                  'height': photo.height,
                })
            .toList(),
        'geometry': _geometryToJson(place),
        'place_id': place.placeId,
        'name': place.name,
      },
    );
  }

  Map<String, Object>? _geometryToJson(PlaceDetails place) {
    if (place.geometry == null) {
      return null;
    }
    return {
      'location': {
        'lat': place.geometry?.location.lat,
        'lng': place.geometry?.location.lng,
      }
    };
  }

  Future<PlaceDetails> getPlaceDetails(
    String placeId,
    bool isAutocomplete,
  ) async {
    if (googlePlacesDb == null) {
      await initLocalDbs();
    }
    PlaceDetails? placeDetails = await _getPlaceDetailsCache(placeId);
    placeDetails ??= await _getPlaceDetailsRemote(placeId, isAutocomplete);
    addPlaceDetailsToCache(placeDetails);
    return placeDetails;
  }

  Future<PlaceDetails?> _getPlaceDetailsCache(String placeId) async {
    RecordSnapshot<String, Map<String, Object?>>? result =
        await store.findFirst(
      googlePlacesDb!,
      finder: Finder(filter: Filter.byKey(placeId)),
    );
    return (result != null) ? PlaceDetails.fromJson(result.value) : null;
  }

  Future<PlaceDetails> _getPlaceDetailsRemote(
    String placeId,
    bool isAutocomplete,
  ) async {
    final response = await _googleMapsPlaces.getDetailsByPlaceId(
      placeId,
      sessionToken: isAutocomplete ? sessionToken : null,
      fields: [
        "geometry",
        "name",
        "photos",
        "icon",
        "place_id",
        "formatted_address",
      ],
    );
    // generate new session token for follow-on autocomplete queries
    if (isAutocomplete) {
      sessionToken = const Uuid().v4();
    }
    debugPrint(response.status);
    debugPrint("Places response: ${response.result.name}");
    return response.result;
  }

  Future<List<Prediction>> searchNearbyPlaces(
    Location location,
    String input,
    int radius,
  ) async {
    PlacesAutocompleteResponse response = await _googleMapsPlaces.autocomplete(
      input,
      sessionToken: sessionToken,
      location: location,
      radius: radius,
      types: ["establishment"],
      language: "en",
      strictbounds: true,
    );
    return response.predictions;
  }
}
