import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// カテゴリー別エリアのスケルトンスクリーン
class CategoryTileSkeleton extends StatefulWidget {
  const CategoryTileSkeleton({super.key});

  @override
  State<CategoryTileSkeleton> createState() => _CategoryTileSkeletonState();
}

class _CategoryTileSkeletonState extends State<CategoryTileSkeleton> {
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
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildSkeletonTile(),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonTile() {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリー名とアイコンのスケルトン
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: MyColors.tirtiarySystemfill.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: MyColors.tirtiarySystemfill.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // グラフバーのスケルトン
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: MyColors.tirtiarySystemfill.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
