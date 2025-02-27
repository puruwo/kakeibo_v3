import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/provider/torok_state/selected_segment_status.dart';

class TorokSelectedSegment extends ConsumerWidget {
  const TorokSelectedSegment({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //呼び出し元で状態管理するのでreadで十分
    //と思ったけど、やっぱりwatchじゃないと動かん
    final selectedSegmentedStatus =
        ref.watch(selectedSegmentStatusNotifierProvider);

    return CupertinoSlidingSegmentedControl<SelectedEnum>(
      backgroundColor: MyColors.secondarySystemfill,
      thumbColor: MyColors.systemGray2,
      // This represents the currently selected segmented control.
      groupValue: selectedSegmentedStatus,
      // Callback that sets the selected segmented control.
      onValueChanged: (SelectedEnum? value) {
        if (value != null) {
          final notifier =
              ref.read(selectedSegmentStatusNotifierProvider.notifier);
          notifier.updateState(value);
        }
      },
      children: const <SelectedEnum, Widget>{
        SelectedEnum.sisyt: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '支出',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
        SelectedEnum.syunyu: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '収入',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
      },
    );
  }
}
