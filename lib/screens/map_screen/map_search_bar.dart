import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 4,
        8,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: kElevationToShadow[6],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: Theme.of(context).textTheme.headline6?.fontSize,
              ),
              onPressed: () {}),
        ],
      ),
    );
  }
}