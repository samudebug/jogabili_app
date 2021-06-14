import 'package:flutter/material.dart';
import 'package:jogabili_app/ui/constants/colors.dart';

class TextStyles {
  static TextStyle episodeTitleStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontFamily: "Roboto",
      fontSize: 20,
      color: Colors.white);
  static TextStyle episodeBlackTitleStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: "Roboto",
    fontSize: 20,
  );

  static TextStyle dateTextStyle = TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: ColorsConstants.dateColor);

  static TextStyle subTitleTextStyle = TextStyle(
      fontFamily: "Roboto", fontWeight: FontWeight.bold, fontSize: 14);

  static TextStyle episodeDescriptionTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: "Roboto",
    fontSize: 14,
  );

  static TextStyle episodeLengthTextStyle(color) {
    return TextStyle(fontFamily: "Roboto", fontSize: 14, color: color);
  }

  static TextStyle episodeTitlePlayerTextStyle(color) {
    return TextStyle(
        fontFamily: "Roboto",
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: color);
  }
}
