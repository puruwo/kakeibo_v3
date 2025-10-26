import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/fixed_cost_constants.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_name_controller/fixed_cost_category_name_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_icon_controller/fixed_cost_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart';

class FixedCostCategoryAppearanceEditArea extends ConsumerStatefulWidget {
  const FixedCostCategoryAppearanceEditArea({
    required this.fixedCostCategoryId,
    super.key,
  });

  final int fixedCostCategoryId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostCategoryAppearanceEditAreaState();
}

class _FixedCostCategoryAppearanceEditAreaState
    extends ConsumerState<FixedCostCategoryAppearanceEditArea> {
  late TextEditingController _nameController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // -1の時は新規作成なので初期化不要
      if (widget.fixedCostCategoryId == -1) {
        // 新規作成時は空の名前で初期化
        _nameController.text = '';
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Future(() async {
        final categories =
            await ref.read(allFixedCostCategoriesProvider.future);
        final initialItem =
            categories.firstWhere((c) => c.id == widget.fixedCostCategoryId);

        // TextEditingControllerに値をセット
        _nameController.text = initialItem.categoryName;

        ref
            .read(fixedCostCategoryNameControllerNotifierProvider.notifier)
            .updateState(initialItem.categoryName);
        ref
            .read(fixedCostCategoryColorControllerNotifierProvider.notifier)
            .updateState(MyColors().getColorFromHex(initialItem.colorCode));
        ref
            .read(fixedCostCategoryIconControllerNotifierProvider.notifier)
            .updateState(initialItem.resourcePath);

        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final iconPath = ref.watch(fixedCostCategoryIconControllerNotifierProvider);
    final color = ref.watch(fixedCostCategoryColorControllerNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                color: MyColors.quarternarySystemfill,
                borderRadius: BorderRadius.circular(18)),
            height: 135,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _showIconSelectDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 18),
                        child: SvgPicture.asset(
                          iconPath,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          semanticsLabel: 'categoryIcon',
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          'assets/images/edit.svg',
                          clipBehavior: Clip.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 313,
                  height: 48,
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    cursorWidth: 2,
                    style: const TextStyle(fontSize: 20, color: MyColors.label),
                    minLines: 1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: MyColors.secondarySystemfill,
                      hintText: "カテゴリー名を入力",
                      hintStyle: const TextStyle(
                          fontSize: 16, color: MyColors.secondaryLabel),
                      contentPadding: const EdgeInsets.only(
                          top: 16, bottom: 0, left: 40, right: 16),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Stack(alignment: Alignment.center, children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: MyColors.systemfill,
                              shape: BoxShape.circle,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              ref
                                  .read(
                                      fixedCostCategoryNameControllerNotifierProvider
                                          .notifier)
                                  .updateState('');
                            },
                            icon: const Icon(Icons.clear,
                                size: 14, color: MyColors.white),
                          ),
                        ]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColors.jet.withOpacity(0.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColors.jet.withOpacity(0.0),
                        ),
                      ),
                    ),
                    keyboardAppearance: Brightness.dark,
                    onChanged: (value) {
                      ref
                          .read(
                              fixedCostCategoryNameControllerNotifierProvider
                                  .notifier)
                          .updateState(value);
                    },
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () async {
            _showColorSelectDialog(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                  color: MyColors.quarternarySystemfill,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8),
                    child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: ref.watch(
                              fixedCostCategoryColorControllerNotifierProvider),
                          shape: BoxShape.circle,
                        )),
                  ),
                  const Text(
                    'カテゴリーカラー',
                    style: TextStyle(fontSize: 14, color: MyColors.label),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showIconSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アイコン選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: FixedCostIcons.iconPathList.length,
              itemBuilder: (context, index) {
                final iconPath = FixedCostIcons.iconPathList[index];
                final color = ref
                    .watch(fixedCostCategoryColorControllerNotifierProvider);
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(fixedCostCategoryIconControllerNotifierProvider
                            .notifier)
                        .updateState(iconPath);
                    Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showColorSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('カラー選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: FixedCostColors.colorList.length,
              itemBuilder: (context, index) {
                final color = FixedCostColors.colorList[index];
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(fixedCostCategoryColorControllerNotifierProvider
                            .notifier)
                        .updateState(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
