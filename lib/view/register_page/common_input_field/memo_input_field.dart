import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';

class MemoInputField extends ConsumerStatefulWidget {
  const MemoInputField({
    super.key,
    required this.originalMemo,
    this.titleLabel = "メモ",
    this.showIcon = false,
  });

  final String originalMemo;
  final String titleLabel;

  /// アイコンを表示するかどうか（DateMemoRow内で使用時はtrue）
  final bool showIcon;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemoInputFieldState();
}

class _MemoInputFieldState extends ConsumerState<MemoInputField> {
  late TextEditingController _enteredMemoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初期値をセット
      _enteredMemoController.text = widget.originalMemo;
    });
  }

  @override
  Widget build(BuildContext context) {
    _enteredMemoController = ref.watch(enteredMemoControllerProvider);

    return Container(
      height: InputPageWidgetSize.pillHeight,
      width: InputPageWidgetSize.pillWidth,
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 20, 5),
        child: SizedBox(
          height: 34,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // アイコン表示（オプション）
              if (widget.showIcon) ...[
                const Icon(
                  Icons.notes_rounded,
                  size: 18,
                  color: MyColors.label,
                ),
                const SizedBox(width: 6),
              ],
              // ラベル
              Text(
                widget.titleLabel,
                textAlign: TextAlign.left,
                style: RegisterPageStyles.placeHolder.copyWith(fontSize: 15),
              ),
              const SizedBox(width: 16),
              // 入力フィールド
              Expanded(
                child: TextFormField(
                  controller: _enteredMemoController,
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.right,
                  cursorColor: MyColors.themeColor,
                  cursorWidth: 2,
                  style: RegisterPageStyles.inputText,
                  minLines: 1,
                  maxLines: 1,
                  maxLength: 20,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  keyboardAppearance: Brightness.dark,
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
    );
  }
}
