import 'package:flutter/material.dart';

customAppBar(title) {
  return AppBar(
    backgroundColor: Colors.white,
    // AppBar 배경 색상
    // elevation: 0.0, //
    centerTitle: false,
    elevation: 0.0,
    title: Text(title,
        style: TextStyle(fontFamily: 'Nanum', fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    leading: IconButton(
      padding: EdgeInsets.only(left: 10),
      onPressed: () => {},
      icon: Icon(
        Icons.sort,
        color: Colors.white,
        size: 25,
      ),
      iconSize: 30,
      color: Colors.white,
    ),
    actions: [
      // IconButton(
      //   icon: Icon(Icons.search),
      //   onPressed: () {},
      //   padding: EdgeInsets.only(right: 30),
      //   iconSize: 30,
      //   color: Colors.black,
      // )
    ],
  );
}
