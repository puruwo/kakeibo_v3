import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/none_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/normal_icon_button.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/selected_icon_button.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';

enum ButtonStatus { selected, normal, none }

enum TransactionMode { expense, income }

class CategoryArea extends ConsumerStatefulWidget {
  const CategoryArea(
      {super.key,
      required this.originalCategoryId,
      required this.transactionMode});
  final int originalCategoryId;
  final TransactionMode transactionMode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CategoryAreaState();
}

class _CategoryAreaState extends ConsumerState<CategoryArea> {
  final pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ICategoryEntity categoryEntity = switch (widget.transactionMode) {
        TransactionMode.expense => await ref
            .watch(categoryUsecaseProvider)
            .fetchBySmallId(widget.originalCategoryId),
        TransactionMode.income => await ref
            .watch(incomeCategoryUsecaseProvider)
            .fetchCategoryBySmallId(widget.originalCategoryId),
      };

      ref
          .read(selectCategoryControllerNotifierProvider.notifier)
          .setData(categoryEntity);
    });
  }

  @override
  Widget build(context) {
//状態管理---------------------------------------------------------------------------------------

    final ICategoryEntity selectCategoryControllerProvider =
        ref.watch(selectCategoryControllerNotifierProvider);

//----------------------------------------------------------------------------------------------

    // 画面の横幅の倍率を取得
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // 画面の縦幅の倍率を取得
    final screenVerticalMagnification = context.screenVerticalMagnification;

    final provider = switch (widget.transactionMode) {
      TransactionMode.expense => allCategoriesProvider,
      TransactionMode.income => allIncomeCategoriesProvider,
    };

    return ref.watch(provider).when(
      data: (list) {
        // 表示するカテゴリーの数
        final categoryQuantity = list.length;

        // 表示するページ数
        final pageQuantity = (categoryQuantity / 15).ceil();

        return SizedBox(
          height: 200 * screenVerticalMagnification,
          width: 343 * screenHorizontalMagnification,
          child: PageView.builder(
            controller: pageController,
            itemCount: pageQuantity,
            itemBuilder: (context, pageIndex) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3, //3行用意する
                    (columnIndex) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //indexの実装
                        children: List.generate(
                          5, //5列用意する
                          (rowIndex) {
                            //ボタンの番号
                            final buttonNumber =
                                pageIndex * 15 + columnIndex * 5 + rowIndex;

                            // ボタン状態の設定
                            // ボタンの番号と選択しているカテゴリーのorderKeyが同じかどうか
                            ButtonStatus buttonStatus = ButtonStatus.normal;
                            // カテゴリー数の範囲外ならnoneに設定する
                            if (buttonNumber + 1 > categoryQuantity) {
                              buttonStatus = ButtonStatus.none;
                            }
                            // ボタンNoと選択しているカテゴリーのキーが同じならselectedにする
                            else if (selectCategoryControllerProvider.id ==
                                list[buttonNumber].id) {
                              buttonStatus = ButtonStatus.selected;
                            }

                            return Padding(
                                // 位置によってpaddingの幅を変える
                                padding: (rowIndex != 0 && rowIndex != 4)
                                    ? const EdgeInsets.symmetric(horizontal: 4)
                                    : (rowIndex == 0)
                                        ? const EdgeInsets.only(right: 4)
                                        : const EdgeInsets.only(left: 4),
                                child: switch (buttonStatus) {
                                  ButtonStatus.selected => SelectedIconButton(
                                      categoryEntity: list[buttonNumber],
                                    ),
                                  ButtonStatus.normal => NormalIconButton(
                                      categoryEntity: list[buttonNumber],
                                    ),
                                  ButtonStatus.none => const NoneIconBox(),
                                });
                          },
                        )),
                  ));
            },
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return const Text('エラーが発生しました');
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }
}
