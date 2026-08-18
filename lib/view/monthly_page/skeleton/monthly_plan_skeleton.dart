import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 今月の計画エリアのスケルトンスクリーン
class MonthlyPlanSkeleton extends StatefulWidget {
  const MonthlyPlanSkeleton({super.key});

  @override
  State<MonthlyPlanSkeleton> createState() => _MonthlyPlanSkeletonState();
}

class _MonthlyPlanSkeletonState extends State<MonthlyPlanSkeleton> {
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 総支出ヘッダーのスケルトン
            Row(
              children: [
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // グラフバーのスケルトン
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: context.colors.fillTertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 総収入ヘッダーのスケルトン
            Row(
              children: [
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.colors.fillTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 収入グラフバーのスケルトン
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: context.colors.fillTertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
