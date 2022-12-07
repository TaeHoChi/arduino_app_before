// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

//앱 중간에 위치한 사진 및 텍스트
Widget CustomImage(String imagename, String textname) {
  return Column(
    children: [
      Image.asset(
        imagename,
        width: 50,
        height: 50,
      ),
      const SizedBox(height: 10),
      Text(
        textname,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}
