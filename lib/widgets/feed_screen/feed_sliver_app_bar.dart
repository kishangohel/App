import 'package:flutter/material.dart';
import 'package:verifi/widgets/feed_screen/feed_filter_chip.dart';

class FeedSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 4.0,
      forceElevated: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FeedFilterChip("Distance"),
              FeedFilterChip("Type")
            ],
          ),
        ),
      ),
      snap: true,
      floating: true,
      pinned: true,
      title: const Text(
        'Nearby WiFi',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
        ),
      ),
      //bottom: FeedFilterBar(),
    );
  }
}
