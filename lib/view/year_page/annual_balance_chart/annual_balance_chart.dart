import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/year_page/annual_balance_chart/parts/annual_balance_chart_painter.dart';
import 'package:kakeibo/view/year_page/annual_balance_chart/parts/annual_balance_tooltip.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_annual_balance_chart_value_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';
import 'package:kakeibo/view_model/state/navigation_bar_number.dart';

class AnnualBalanceChart extends ConsumerStatefulWidget {
  const AnnualBalanceChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnnualBalanceChartState();
}

class _AnnualBalanceChartState extends ConsumerState<AnnualBalanceChart> {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: false,
  );

  int? _selectedMonthIndex;
  bool _didInitialScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(resolvedAnnualBalanceChartValueProvider).when(
          data: (chartData) {
            if (chartData.hasNoRecord) {
              return CardContainer(
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text('まだ記録がありません', style: AppTextStyles.errorMessage),
                ),
              );
            }

            // 初期スクロール位置の設定（初回の build 時のみ実行）
            if (!_didInitialScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_scrollController.hasClients) return;
                if (_didInitialScroll) return;
                _didInitialScroll = true;
                final pos = _scrollController.position;
                if (chartData.monthIndex <= 3) {
                  _scrollController.animateTo(
                    pos.minScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (chartData.monthIndex <= 7) {
                  _scrollController.animateTo(
                    pos.maxScrollExtent / 2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _scrollController.animateTo(
                    pos.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              });
            }

            // データの黒字/赤字有無から動的にバー領域の高さを決定する
            final dimensions = AnnualBalanceChartDimensions.from(
              chartData.monthlyBalanceValues,
            );

            // CardContainerが実際に描画する色（背景のsurfaceElevatedにfillQuaternaryを
            // 合成した色）。Y軸ラベルオーバーレイの境界を見えなくするために使う
            final cardSurfaceColor = Color.alphaBlend(
              context.colors.fillQuaternary,
              context.colors.surfaceElevated,
            );

            return CardContainer(
              width: AnnualBalanceChartLayout.scrollAreaWidth,
              child: Stack(
                children: [
                  // スクロール可能な本体グラフ（グリッド / 折れ線 / 棒 / 月ラベル）
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AnnualBalanceChartLayout.horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: SizedBox(
                        width: AnnualBalanceChartLayout.drawingAreaWidth,
                        height: dimensions.totalHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) => _updateSelection(
                                details.localPosition,
                                chartData.monthlyBalanceValues,
                                dimensions,
                              ),
                              onLongPressStart: (details) => _updateSelection(
                                details.localPosition,
                                chartData.monthlyBalanceValues,
                                dimensions,
                              ),
                              onLongPressMoveUpdate: (details) =>
                                  _updateSelection(
                                details.localPosition,
                                chartData.monthlyBalanceValues,
                                dimensions,
                              ),
                              child: CustomPaint(
                                size: Size(
                                  AnnualBalanceChartLayout.drawingAreaWidth,
                                  dimensions.totalHeight,
                                ),
                                painter: AnnualBalanceChartPainter(
                                  value: chartData,
                                  selectedMonthIndex: _selectedMonthIndex,
                                  dimensions: dimensions,
                                  separator: context.colors.separator,
                                  income: context.colors.income,
                                  expense: context.colors.expense,
                                ),
                              ),
                            ),
                            if (_selectedMonthIndex != null)
                              _buildTooltip(
                                chartData.monthlyBalanceValues[
                                    _selectedMonthIndex!],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 固定表示の Y軸ラベルオーバーレイ（左端は CardContainer と同色、右に向けてフェードアウト）
                  //
                  // fillOpaqueは不透明トークンでCardContainerの半透明fillQuaternaryとは
                  // 別物のため、そのまま使うと縦軸ラベル付近に境界線が見えてしまう。
                  // CardContainerが実際に描画する色（fillQuaternaryをsurfaceElevated上に
                  // 合成した色）を計算して使うことで境界をなくす。
                  //
                  // 背景のグラデーションはCardContainerの上下端（Widget全体の高さ）まで
                  // 塗り広げる。スクロール本体側は上下16pxのPaddingを持つため、
                  // オーバーレイをグラフ本体と同じ高さ（top:16〜totalHeight）だけに
                  // 留めると、カードの上端・下端の16px帯に背景が塗られず境界に見える。
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  cardSurfaceColor,
                                  cardSurfaceColor,
                                  cardSurfaceColor.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                            child: SizedBox(
                              width: AnnualBalanceChartLayout.reservedSize,
                              height: double.infinity,
                            ),
                          ),
                          // ラベル文字はグラフ本体と同じ位置（上16px）に描画する
                          Positioned(
                            left: 0,
                            top: 16.0,
                            child: CustomPaint(
                              size: Size(
                                AnnualBalanceChartLayout.reservedSize,
                                dimensions.totalHeight,
                              ),
                              painter: AnnualBalanceAxisLabelsPainter(
                                scale: chartData.yAxisScale,
                                dimensions: dimensions,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return const AppErrorState();
          },
          // ローディングはトップレベル(PageLoadingIndicator)で吸収する
          loading: () => const SizedBox.shrink(),
        );
  }

  void _updateSelection(
    Offset position,
    List<MonthlyBalanceValue> values,
    AnnualBalanceChartDimensions dimensions,
  ) {
    final idx = AnnualBalanceChartLayout.hitTestCell(
      position,
      monthLabelTopY: dimensions.monthLabelTop,
    );
    // 範囲外 or 未来月 → 閉じる
    if (idx == null ||
        values[idx].monthlyBalanceType == MonthlyBalanceType.future) {
      if (_selectedMonthIndex != null) {
        setState(() => _selectedMonthIndex = null);
      }
      return;
    }
    if (_selectedMonthIndex == idx) return;
    setState(() => _selectedMonthIndex = idx);
  }

  Widget _buildTooltip(MonthlyBalanceValue selected) {
    // ツールチップ幅（実測で中央寄せ制御するほどではないので固定幅運用）
    const tooltipWidth = 160.0;
    final cx = AnnualBalanceChartLayout.cellCenterX(_selectedMonthIndex!);
    double left = cx - tooltipWidth / 2;
    // Y軸ラベルオーバーレイ(reservedSize幅)より左にならないよう防止
    if (left < AnnualBalanceChartLayout.reservedSize) {
      left = AnnualBalanceChartLayout.reservedSize;
    }
    if (left + tooltipWidth > AnnualBalanceChartLayout.drawingAreaWidth) {
      left = AnnualBalanceChartLayout.drawingAreaWidth - tooltipWidth;
    }

    return Positioned(
      left: left,
      top: 0,
      width: tooltipWidth,
      child: AnnualBalanceTooltip(
        value: selected,
        onTap: () {
          ref
              .read(analyzePageSelectedDatetimeNotifierProvider.notifier)
              .updateState(selected.representativeDate);
          ref
              .read(navigationBarNumberNotifierProvider.notifier)
              // 月間分析タブ（グロナビ index 1）へ遷移する
              .updateState(1);
          setState(() => _selectedMonthIndex = null);
        },
      ),
    );
  }
}
