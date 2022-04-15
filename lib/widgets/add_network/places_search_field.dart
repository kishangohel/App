import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/blocs/blocs.dart';

class PlacesSearchField extends StatelessWidget {
  final TextEditingController _textEditingController;
  PlacesSearchField(this._textEditingController) : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: _textEditingController,
        onChanged: (text) {
          context.read<MapSearchCubit>().updateQuery(
                LatLon(
                  context.read<MapCubit>().currentPosition?.target.latitude ??
                      -1.0,
                  context.read<MapCubit>().currentPosition?.target.longitude ??
                      -1.0,
                ),
                text,
              );
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Search nearby places...",
        ),
      ),
    );
  }
}
