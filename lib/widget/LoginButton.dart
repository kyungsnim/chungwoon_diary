import 'package:flutter/material.dart';

Widget loginButton(context, image, title, tColor, bColor, oColor) {
  return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: oColor),
          color: bColor,
          boxShadow: [
            BoxShadow(offset: Offset(1, 1), blurRadius: 5, color: Colors.black12)
          ]
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.023,
              child: Image(image: AssetImage(image,))
          ),
          SizedBox(width: 10),
          Text(
              title,
              style: TextStyle(fontFamily: 'Nanum', 
                  color: tColor,
                  // fontWeight: FontWeight.bold,
                  fontSize: 20
              )
          ),
        ],
      )
  );
}