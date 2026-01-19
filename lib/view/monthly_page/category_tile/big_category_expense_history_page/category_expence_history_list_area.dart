import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/constant/strings.dart';
// DateTimeの日本語対応
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_expense_history_value_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// Local imports
import 'package:kakeibo/util/screen_size_func.dart';

enum ListAreaMode { bigCategory, smallCategory }

// カテゴリー指定して支出履歴を表示するエリア

class CategoryExpenceHistoryArea extends ConsumerStatefulWidget {
  CategoryExpenceHistoryArea(
      {super.key, required this.listAreaMode, this.bigId, this.smallId});
  final ListAreaMode listAreaMode;
  final int? bigId;
  final int? smallId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoryExpenceHistoryArea();

  final AutoScrollController _scrollController = AutoScrollController();
}

class _CategoryExpenceHistoryArea
    extends ConsumerState<CategoryExpenceHistoryArea> {
  List<DateTime> itemKeys = [];

  @override
  Widget build(BuildContext context) {
    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(context.screenWidth);

    // リスト内テキストボックスの倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final listSmallcategoryMemoOffset = context.listSmallcategoryMemoOffset;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // DateTimeの日本語対応
    initializeDateFormatting();

//状態管理---------------------------------------------------------------------------------------

    // selectedDatetimeが更新されたら動く
    ref.listen(historicalSelectedDatetimeNotifierProvider, (previous, next) {
      final updatedSelectedDateTime = next;
      _scrollToItem(
          updatedSelectedDateTime, itemKeys, widget._scrollController);
    });

//----------------------------------------------------------------------------------------------

    final provider = switch (widget.listAreaMode) {
      ListAreaMode.bigCategory =>
        resolvedCategoryExpenseHistoryDigestValueProvider(widget.bigId!),
      ListAreaMode.smallCategory =>
        resolvedSmallCategoryExpenseHistoryDigestValueProvider(widget.smallId!),
    };

    return ref.watch(provider).when(data: (tileGroupList) {
      Widget children;

      if (tileGroupList.isNotEmpty) {
        return Expanded(
          child: ListView.builder(
            controller: widget._scrollController,
            itemCount: tileGroupList.length,
            itemBuilder: (BuildContext context, int index) {
              itemKeys = tileGroupList.map((e) => e.date).toList();

              return AutoScrollTag(
                key: ValueKey(index),
                index: index,
                controller: widget._scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 日付ヘッダーの上スペース
                    const SizedBox(
                      height: 13,
                    ),
                    //日付ラベル
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: leftsidePadding),
                          child: Text(
                              DateFormat('yyyy年M月d日(E)', 'ja_JP')
                                  .format(tileGroupList[index].date),
                              style: HistoryListStyles
                                  .expenseHistoryDateHeaderLabel),
                        ),
                        //右余白
                      ],
                    ),

                    //区切り線
                    Divider(
                      thickness: 0.25,
                      height: 0.25,
                      indent: leftsidePadding,
                      endIndent: leftsidePadding,
                      color: MyColors.separater,
                    ),

                    //タイル
                    ...tileGroupList[index].expenseHistoryTileValueList.map(
                          (value) => ExpenseItemTile(
                            value: value,
                            leftsidePadding: leftsidePadding,
                            listSmallcategoryMemoOffset:
                                listSmallcategoryMemoOffset,
                            screenHorizontalMagnification:
                                screenHorizontalMagnification,
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        children = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                '記録がまだありません',
                style: AppTextStyles.listEmptyMessage,
              ),
            ),
          ],
        );
      }

      return children;
    }, error: (error, stackTrace) {
      return const Center(
        child: Text('データの取得に失敗しました'),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  void _scrollToItem(
      DateTime dt, List keysList, AutoScrollController controller) async {
    final index = keysList.indexOf(dt);
    await controller.scrollToIndex(
      index,
      duration: const Duration(milliseconds: 500),
      preferPosition: AutoScrollPosition.begin,
    );
    await controller.highlight(index);
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return screenWidthSize - defaultWidth;
  }
}
