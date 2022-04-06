import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/widgets/search_results_list_item.dart';

class PlacesSearchResultsListItem extends StatelessWidget {
  final AutocompletePrediction prediction;
  final TextEditingController nameController;
  const PlacesSearchResultsListItem(
    this.prediction,
    this.nameController,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //nameController.text = prediction.description;
      },
      child: SearchResultsListItem(prediction),
    );
  }
}
