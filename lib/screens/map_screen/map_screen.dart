import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/screens/map_screen/map_buttons/map_buttons.dart';

import 'map_flutter_map.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (context) => MapCubit(
        RepositoryProvider.of<AccessPointRepository>(context),
      ),
      child: Stack(
        children: [
          MapFlutterMap(),
          MapButtons(),
        ],
      ),
    );
  }
}
