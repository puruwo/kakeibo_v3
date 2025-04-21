import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view_model/state/register_page/torok_state.dart';

class DateDisplay extends ConsumerWidget {
  const DateDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    final provider = ref.watch(torokRecordNotifierProvider);

    return GestureDetector(
      onTap: () async {
        //providerを取得
        final provider = ref.read(torokRecordNotifierProvider);
        //現在の選択日付を取得
        final dt = DateTime.parse(provider.date);

        //カレンダーピッカーで日付を選択し取得
        final DateTime? picked = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: dt, // 最初に表示する日付
          firstDate: DateTime(2020), // 選択できる日付の最小値
          lastDate: DateTime(2025), // 選択できる日付の最大値
        );

        //notifierを取得
        final notifier = ref.read(torokRecordNotifierProvider.notifier);
        //nullチェックせなあかん
        if (picked != null) {
          notifier.updateDate(picked);
        } else {
          print(e);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.secondarySystemfill,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        width: 343 * screenHorizontalMagnification,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '${provider.date.substring(0, 4)}年${int.parse(provider.date.substring(4, 6)).toString()}月${int.parse(provider.date.substring(6, 8)).toString()}日',
                textAlign: TextAlign.right,
                style: const TextStyle(color: MyColors.white, fontSize: 17),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: MyColors.secondaryLabel,
              ),
            )
          ],
        ),
      ),
    );
  }
}
