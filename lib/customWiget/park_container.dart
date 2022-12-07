// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

//적외선 센서에 인식이되면 상자가 초록색으로 바뀐다.
Widget parkContainer(String number) {
  return Container(
    width: 50,
    height: 50,
    color: Colors.white,
    child: Center(
        child: Text(
      number,
      style: TextStyle(color: Colors.black, fontSize: 20),
    )),
  );
}
