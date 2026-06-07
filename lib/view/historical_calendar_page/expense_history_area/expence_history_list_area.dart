import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/history_list_skeleton.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/transaction_group_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_transaction_history_value_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ExpenceHistoryArea extends ConsumerStatefulWidget {
  ExpenceHistoryArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenceHistoryAreaState();

  final AutoScrollController _scrollController = AutoScrollController();
}

class _ExpenceHistoryAreaState extends ConsumerState<ExpenceHistoryArea> {
  List<DateTime> itemKeys = [];

  @override
  Widget build(BuildContext context) {
    // 画面の倍率を計算
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(context.screenWidth);

    // リスト内テキストボックスの倍率を計算
    final listSmallcategoryMemoOffset = context.listSmallcategoryMemoOffset;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // DateTimeの日本語対応
    initializeDateFormatting();

    // extendBody:true のボトムナビ背後までリストが広がるため、
    // MediaQuery では取得できない下部セーフエリアを View から直接取得し、
    // ボトムナビ高さとあわせて末尾余白に加算する（最後の項目が隠れないように）
    final view = View.of(context);
    final bottomSafeArea = view.padding.bottom / view.devicePixelRatio;
    final bottomInset = kBottomNavigationBarHeight + bottomSafeArea + 24;

    // selectedDatetimeが更新されたら動く
    ref.listen(historicalSelectedDatetimeNotifierProvider, (previous, next) {
      final updatedSelectedDateTime = next;
      // 日が変わったタイミングだけでスクロールする
      if (previous?.day != updatedSelectedDateTime.day) {
        _scrollToItem(
            updatedSelectedDateTime, itemKeys, widget._scrollController);
      }
    });

    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: ref.watch(resolvedTransactionHistoryValueProvider).when(
            data: (tileGroupList) {
          if (tileGroupList.isNotEmpty) {
            return ListView.builder(
              key: const ValueKey('data'),
              controller: widget._scrollController,
              itemCount: tileGroupList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                // リスト末尾のスペーサー
                if (index == tileGroupList.length) {
                  return SizedBox(height: bottomInset);
                }

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
                                style: AppTextStyles.listTileSectionTitle),
                          ),
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
                      TransactionHistoryGroupTile(
                        group: tileGroupList[index],
                        leftsidePadding: leftsidePadding,
                        listSmallcategoryMemoOffset:
                            listSmallcategoryMemoOffset,
                        screenHorizontalMagnification:
                            screenHorizontalMagnification,
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Column(
              key: const ValueKey('empty'),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
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
        }, error: (error, stackTrace) {
          return const Center(
            key: ValueKey('error'),
            child: Text('データの取得に失敗しました'),
          );
        }, loading: () {
          return const HistoryListSkeleton(
            key: ValueKey('loading'),
          );
        }),
      ),
    );
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
}
