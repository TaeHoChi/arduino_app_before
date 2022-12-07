// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

//정보에 관한 텍스트
Widget down_TextFont(String name, String name2) {
  return Row(
    children: [
      Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 10),
      const Text(':'),
      const SizedBox(width: 10),
      //위치마다 바뀔 값
      Text(name2)
    ],
  );
}
