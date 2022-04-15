import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class SearchResultsListItem extends StatelessWidget {
  final AutocompletePrediction searchResult;
  const SearchResultsListItem(this.searchResult);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                searchResult.description ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            flex: 9,
          ),
        ],
      ),
    );
  }
}
