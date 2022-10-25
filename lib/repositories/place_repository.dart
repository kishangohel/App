import 'package:flutter/foundation.dart';
import 'package:google_place/google_place.dart';
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
  late GooglePlace _googleMapsPlaces;

  PlaceRepository() {
    _googleMapsPlaces = GooglePlace(
      'AIzaSyAvSlAS6yLh5Nt1WuhEeTOOL_nDrLTAALo',
    );
  }

  String get apiKey => _googleMapsPlaces.apiKEY;

  Future<void> initLocalDbs() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, googlePlacesDbFilename);
    googlePlacesDb = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> addPlaceDetailsToCache(DetailsResult place) async {
    if (googlePlacesDb == null) {
      await initLocalDbs();
    }
    await store.record(place.placeId!).put(
      googlePlacesDb!,
      {
        'formatted_address': place.formattedAddress,
        'icon': place.icon,
        'photos': place.photos
            ?.map((photo) => {
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

  Map<String, Object>? _geometryToJson(DetailsResult place) {
    if (place.geometry == null) {
      return null;
    }
    return {
      'location': {
        'lat': place.geometry!.location!.lat,
        'lng': place.geometry!.location!.lng,
      }
    };
  }

  Future<DetailsResult?> getPlaceDetails(
    String? placeId,
    bool isAutocomplete,
  ) async {
    if (googlePlacesDb == null) {
      await initLocalDbs();
    }
    if (placeId == null) {
      return null;
    }
    DetailsResult? placeDetails = await _getPlaceDetailsCache(placeId);
    placeDetails ??= await _getPlaceDetailsRemote(placeId, isAutocomplete);
    if (placeDetails != null) addPlaceDetailsToCache(placeDetails);
    return placeDetails;
  }

  Future<DetailsResult?> _getPlaceDetailsCache(String placeId) async {
    RecordSnapshot<String, Map<String, Object?>>? result =
        await store.findFirst(
      googlePlacesDb!,
      finder: Finder(filter: Filter.byKey(placeId)),
    );
    return (result != null) ? DetailsResult.fromJson(result.value) : null;
  }

  Future<DetailsResult?> _getPlaceDetailsRemote(
    String placeId,
    bool isAutocomplete,
  ) async {
    final response = await _googleMapsPlaces.details.get(
      placeId,
      sessionToken: isAutocomplete ? sessionToken : null,
      fields: "geometry,name,photos,icon,place_id,formatted_address",
    );
    // generate new session token for follow-on autocomplete queries
    if (isAutocomplete) {
      sessionToken = const Uuid().v4();
    }
    debugPrint("${response?.status}");
    debugPrint("Places response: ${response?.result?.name}");
    return response?.result;
  }

  Future<List<AutocompletePrediction>?> searchNearbyPlaces(
    LatLon location,
    String input,
  ) async {
    AutocompleteResponse? response = await _googleMapsPlaces.autocomplete.get(
      input,
      sessionToken: sessionToken,
      location: location,
      radius: 200,
      types: "establishment",
      language: "en",
      strictbounds: true,
    );
    return response?.predictions;
  }

  // This should only be used by background activity auto-connect service and
  // not for map searches or main UI.
  //
  Future<NearBySearchResponse?> getNearbyPlaces(Location location) {
    return _googleMapsPlaces.search.getNearBySearch(
      location,
      20, // 20 meter radius
    );
  }
}
