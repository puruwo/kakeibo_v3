// import 'package:flutter/material.dart';

// import 'package:kakeibo/constant/colors.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// double width = 46.0;

// Container vacantDateBox(
//     int weekday, String dateLabel, double boxHeight) {
//   return Container(
//     width: width,
//     height: boxHeight,
//     decoration: const BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(6)),
//     ),
//     child: Center(
//       child: Column(
//         children: [
//           Text(dateLabel,
//               style: const TextStyle(color: MyColors.tirtiaryLabel)),
//         ],
//       ),
//     ),
//   );
// }

// Container normalDateBox(
//     int weekday, String dateLabel, Text priceLabel, double boxHeight) {
//   return Container(
//     width: width,
//     height: boxHeight,
//     decoration: const BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(6)),
//     ),
//     child: Center(
//       child: Column(
//         children: [
//           Text(
//             dateLabel,
//             style: TextStyle(
//               color: weekday == 7
//                   ? MyColors.blue
//                   : weekday == 1
//                       ? MyColors.red
//                       : MyColors.secondaryLabel,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 1.0),
//             child: SizedBox(
//               width: width,
//               child: priceLabel,
//               ),
//           )
//         ],
//       ),
//     ),
//   );
// }

// Container activeDateBox(
//     int weekday, String dateLabel, Text priceLabel, double boxHeight) {
//   return Container(
//     width: width,
//     height: boxHeight,
//     decoration: const BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(6)),
//         color: MyColors.tirtiarySystemfill),
//     child: Center(
//       child: Column(
//         children: [
//           Text(
//             dateLabel,
//             style: TextStyle(
//               color: weekday == 7
//                   ? MyColors.blue
//                   : weekday == 1
//                       ? MyColors.red
//                       : MyColors.secondaryLabel,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 1.0),
//             child: SizedBox(
//               width: width,
//               child: priceLabel,
//               ),
//           )
//         ],
//       ),
//     ),
//   );
// }
