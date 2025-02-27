import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 322,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('日', style: TextStyle(color: MyColors.red, fontSize: 12)),
          Text('月', style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
          Text('火', style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
          Text('水', style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
          Text('木', style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
          Text('金', style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
          Text('土', style: TextStyle(color: MyColors.blue, fontSize: 12)),
        ],
      ),
    );
  }
}
