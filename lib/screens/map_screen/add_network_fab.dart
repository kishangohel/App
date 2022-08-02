import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:verifi/widgets/add_network/add_network_page.dart';

class AddNetworkFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      icon: const Icon(Icons.wifi),
      label: Text(
        "Add Network",
        style: Theme.of(context).textTheme.button?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      elevation: 6.0,
      onPressed: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: AddNetworkPage(),
          ),
        );
      },
    );
  }
}
