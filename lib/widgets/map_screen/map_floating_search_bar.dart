import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/blocs/map/map_cubit.dart';
import 'package:verifi/blocs/map_search/map_search.dart';

class MapFloatingSearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapFloatingSearchBarState();
}

class MapFloatingSearchBarState extends State<MapFloatingSearchBar> {
  final controller = FloatingSearchBarController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapSearchCubit, MapSearchState>(
        builder: (context, mapSearchState) {
      return FloatingSearchBar(
        progress: mapSearchState.loading,
        scrollPadding: const EdgeInsets.symmetric(vertical: 8.0),
        controller: controller,
        transitionDuration: const Duration(milliseconds: 300),
        hint: "Search a new place",
        hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
              color: Colors.grey[700],
              fontSize: 18,
            ),
        physics: const BouncingScrollPhysics(),
        debounceDelay: const Duration(milliseconds: 300),
        transition: SlideFadeFloatingSearchBarTransition(),
        onQueryChanged: (query) => context.read<MapSearchCubit>().updateQuery(
              LatLon(
                context.read<LocationCubit>().state!.latitude,
                context.read<LocationCubit>().state!.longitude,
              ),
              query,
            ),
        actions: _buildActions(),
        builder: (context, transition) => _buildResults(),
      );
    });
  }

  List<FloatingSearchBarAction> _buildActions() => [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
          duration: const Duration(milliseconds: 600),
        ),
      ];

  Widget _buildResults() {
    return BlocBuilder<MapSearchCubit, MapSearchState>(
        builder: (context, state) {
      if (state.predictions != null) {
        return SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: state.predictions?.length ?? 0,
                separatorBuilder: (context, index) {
                  return Container(
                    height: 1,
                    color: Colors.grey,
                  );
                },
                itemBuilder: (context, index) {
                  return _buildSearchResultItem(state.predictions![index]);
                },
              ),
            ),
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const Text("No results..."),
        );
      }
    });
  }

  Widget _buildSearchResultItem(AutocompletePrediction prediction) {
    final name = prediction.terms![0].value!;
    final description =
        prediction.terms?.sublist(1).map((term) => term.value).join(", ");
    return GestureDetector(
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(description!),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => _handlePlacesSearchTap(prediction.placeId),
    );
  }

  Future<void> _handlePlacesSearchTap(String? placeId) async {
    if (placeId != null) {
      await context.read<MapSearchCubit>().getWifiAtPlaceId(placeId);
      FocusScope.of(context).unfocus();
      context.read<MapCubit>().mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                context
                        .read<MapSearchCubit>()
                        .state
                        .selectedPlace!
                        .placeDetails!
                        .geometry!
                        .location
                        ?.lat ??
                    -1.0,
                context
                        .read<MapSearchCubit>()
                        .state
                        .selectedPlace!
                        .placeDetails!
                        .geometry!
                        .location
                        ?.lng ??
                    -1.0,
              ),
              18,
            ),
          );
    }
  }
}
