import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/widgets/feed_screen/feed_card.dart';
import 'package:verifi/widgets/feed_screen/feed_sliver_app_bar.dart';

class FeedScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  Completer _refreshCompleter = Completer<void>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LatLng?>(
        builder: (context, locationState) {
      return BlocBuilder<WifiFeedCubit, WifiFeedState>(
          builder: (context, wifiFeedState) {
        if (wifiFeedState.wifis != null) {
          _refreshCompleter.complete();
          _refreshCompleter = Completer<void>();
        } else if (locationState != null) {
          context.read<WifiFeedCubit>().loadFeed(locationState);
        }
        return Container(
          color: Colors.white,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                FeedSliverAppBar(),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () {
                if (locationState != null) {
                  context.read<WifiFeedCubit>().loadFeed(locationState);
                }
                return _refreshCompleter.future;
              },
              child: (locationState != null)
                  ? _buildWifiFeed(wifiFeedState.wifis, locationState)
                  : _buildLocationAccessNotice(context),
            ),
          ),
        );
      });
    });
  }

  Widget _buildWifiFeed(List<Wifi>? wifis, LatLng myLocation) {
    if (wifis != null && wifis.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index) {
          return FeedCard(
              wifiDetails: wifis[index].wifiDetails!, // only null if cluster
              placeDetails: wifis[index].placeDetails!, // only null if cluster
              myLocation: myLocation);
        },
        itemCount: wifis.length,
      );
    } else if (wifis == null) {
      return const LinearProgressIndicator();
    } else {
      return const Center(child: Text("No wifis nearby"));
    }
  }

  Widget _buildLocationAccessNotice(BuildContext context) {
    return const Center(child: Text("Location disabled..."));
  }
}
