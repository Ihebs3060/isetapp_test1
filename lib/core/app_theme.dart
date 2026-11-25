import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF005B7F);

String getFormattedDate() {
  final now = DateTime.now();
  final months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return "${now.day} ${months[now.month - 1]} ${now.year}";
}
