import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';

class CalendarMonthDisplay extends StatelessWidget {
  const CalendarMonthDisplay({required this.label,super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(label,style: TextStyle(color: MyColors.white,fontSize: 20),),);
  }
}