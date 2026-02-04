import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/screen_size_func.dart';

/// ヒストリカルエリアのスケルトンスクリーン
class HistoryListSkeleton extends StatefulWidget {
  const HistoryListSkeleton({super.key});

  @override
  State<HistoryListSkeleton> createState() => _HistoryListSkeletonState();
}

class _HistoryListSkeletonState extends State<HistoryListSkeleton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // 100ms以下のローディングなら表示しない
    // 100ms後にフェードインを開始する
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(context.screenWidth);
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: SingleChildScrollView(
        // スクロールはできないようにする
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(4, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 13),
                // 日付ヘッダーのスケルトン
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: leftsidePadding),
                      child: Container(
                        width: 150,
                        height: 16,
                        decoration: BoxDecoration(
                          color: MyColors.tirtiarySystemfill.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                // 区切り線
                Divider(
                  thickness: 0.25,
                  height: 0.25,
                  indent: leftsidePadding,
                  endIndent: leftsidePadding,
                  color: MyColors.separater,
                ),
                // リストアイテムのスケルトン(2個)
                ...List.generate(2, (itemIndex) {
                  return _buildSkeletonItem(leftsidePadding);
                }),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Row(
        children: [
          // アイコン部分
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MyColors.tirtiarySystemfill.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // テキスト部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: MyColors.tirtiarySystemfill.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 金額部分
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: MyColors.tirtiarySystemfill.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
