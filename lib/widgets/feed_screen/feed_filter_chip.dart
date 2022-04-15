import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/models.dart';

class FeedFilterChip extends StatelessWidget {
  final String label;

  const FeedFilterChip(this.label);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedFilterBloc, FeedFilter>(
        builder: (context, feedFilter) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ActionChip(
          onPressed: () {
            if (label == "Distance") {
              showPickerNumber(context);
            }
          },
          elevation: 4.0,
          labelPadding: const EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 16.0,
          ),
          backgroundColor: Colors.red,
          label: Text(
            (label == "Distance")
                ? "$label: ${feedFilter.distance} miles"
                : "Type",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    });
  }

  Future<void> showPickerNumber(BuildContext context) async {
    Picker(
      adapter: NumberPickerAdapter(data: [
        const NumberPickerColumn(items: [1, 5, 10, 25, 50, 100, 200]),
      ]),
      hideHeader: true,
      title: const Text("Select Maximum Distance"),
      onConfirm: (Picker picker, List<int> value) {
        BlocProvider.of<WifiFeedCubit>(context).filter.distance =
            picker.getSelectedValues()[0].toDouble();
      },
    ).showDialog(context);
  }
}
