import 'package:flutter/material.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top+8, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 4.0),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
    );
  }
}
