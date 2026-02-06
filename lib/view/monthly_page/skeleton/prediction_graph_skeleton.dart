import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// 支出グラフのスケルトンスクリーン
class PredictionGraphSkeleton extends StatefulWidget {
  const PredictionGraphSkeleton({super.key});

  @override
  State<PredictionGraphSkeleton> createState() =>
      _PredictionGraphSkeletonState();
}

class _PredictionGraphSkeletonState extends State<PredictionGraphSkeleton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
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
    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: CardContainer(
        height: 240,
        width: 343 * screenHorizontalMagnification,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分のスケルトン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: MyColors.tirtiarySystemfill.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: MyColors.tirtiarySystemfill.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // グラフエリアのスケルトン
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final heights = [0.4, 0.5, 0.6, 0.55, 0.7, 0.65, 0.3];
                    return Container(
                      width: 30,
                      height: 150 * heights[index],
                      decoration: BoxDecoration(
                        color: MyColors.tirtiarySystemfill.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              // X軸ラベルのスケルトン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  return Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: MyColors.tirtiarySystemfill.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
