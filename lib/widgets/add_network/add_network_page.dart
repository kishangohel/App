import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/widgets/add_network/password_field.dart';
import 'package:verifi/widgets/add_network/places_search_field.dart';
import 'package:verifi/widgets/add_network/ssid_field.dart';

class AddNetworkPage extends StatelessWidget {
  final TextEditingController placeNameTextEditingController =
      TextEditingController();
  final TextEditingController ssidTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final TextEditingController placeIdTextEditingController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, authenticationState) {
      return BlocBuilder<MapSearchCubit, MapSearchState>(
          builder: (context, mapSearchState) {
        return BlocBuilder<MapCubit, MapState>(builder: (context, mapState) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Add Network"),
            ),
            body: Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // SSID Field
                  SSIDField(ssidTextEditingController),
                  // Password Field
                  PasswordField(passwordTextEditingController),
                  // Google Places Search Field
                  PlacesSearchField(placeNameTextEditingController),
                  //       Expanded(
                  //         child: ListView.builder(
                  //           itemBuilder: (BuildContext context, int index) {
                  //             return (mapSearchState.predictions !=)
                  //                 ? PlacesSearchResultsListItem(
                  //                     mapSearchState.results[index],
                  //                     placeNameTextEditingController,
                  //                   )
                  //                 : null;
                  //           },
                  //           itemCount: (mapSearchState is MapSearchLoaded)
                  //               ? mapSearchState.results.length
                  //               : 0,
                  //           padding: EdgeInsets.all(0.0),
                  //           shrinkWrap: true,
                  //         ),
                  //       ),
                ],
              ),
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   label: Text("Submit"),
            //   onPressed: () {
            //     (mapSearchState is MapSearchSelected)
            //         ? context.bloc<AddNetworkBloc>().add(
            //               AddNetworkSubmit(
            //                 WifiDetails(
            //                   location: LatLng(
            //                     mapSearchState
            //                         .selectedPlace.geometry.location.lat,
            //                     mapSearchState
            //                         .selectedPlace.geometry.location.lng,
            //                   ),
            //                   ssid: ssidTextEditingController.text,
            //                   password: passwordTextEditingController.text,
            //                   placeId: mapSearchState.selectedPlace.placeId,
            //                   submittedBy: (authenticationState
            //                           is AuthenticationStateAuthenticated)
            //                       ? authenticationState.uid
            //                       : null,
            //                 ),
            //               ),
            //             )
            //         : Scaffold.of(context).showSnackBar(SnackBar(
            //             content: Text("Unable to add wifi at this time"),
            //           ));
            //     Navigator.of(context).pop();
            //   },
            // ),
            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.centerFloat,
          );
        });
      });
    });
  }
}
