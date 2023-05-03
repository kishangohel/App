import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/src/features/achievement/presentation/achievements_body.dart';

import 'rankings_body.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.only(bottom: 8.0),
                splashBorderRadius: BorderRadius.circular(8.0),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FaIcon(
                          (_selectedIndex == 0)
                              ? FontAwesomeIcons.solidTrophy
                              : FontAwesomeIcons.trophy,
                        ),
                        const SizedBox(width: 10),
                        const Text('Achievements'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        FaIcon(FontAwesomeIcons.listOl),
                        SizedBox(width: 10),
                        Text('Rankings'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          AchievementsBody(),
          RankingsBody(),
        ]),
      ),
    );
  }
}
