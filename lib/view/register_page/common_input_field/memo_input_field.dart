import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_pill_container.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 追加モードで既に初期化済みの場合は、入力値を保持するためスキップ
      final isInitialized = ref.read(inputInitializedControllerProvider);
      final mode = ref.read(registerScreenModeNotifierProvider);
      if (mode == RegisterScreenMode.add && isInitialized) {
        return;
      }
      // 初期値をセット
      _enteredMemoController.text = widget.originalMemo;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _enteredMemoController = ref.watch(enteredMemoControllerProvider);

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      // ADR-017実装メモ: 独自Containerではなく共通のAppPillContainerを経由する
      // （境界線等の見た目の変更が1箇所に集約されるようにする）
      child: AppPillContainer(
        width: InputPageWidgetSize.pillWidth,
        padding: const EdgeInsets.fromLTRB(16, 6, 20, 5),
        child: SizedBox(
          height: 34,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // アイコン表示（オプション）
              if (widget.showIcon) ...[
                Icon(
                  Icons.notes_rounded,
                  size: 18,
                  color: context.colors.text,
                ),
                const SizedBox(width: 6),
              ],
              // ラベル
              Text(
                widget.titleLabel,
                textAlign: TextAlign.left,
                style: RegisterPageStyles.placeHolder,
              ),
              const SizedBox(width: 16),
              // 入力フィールド
              Expanded(
                child: TextFormField(
                  controller: _enteredMemoController,
                  focusNode: _focusNode,
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.right,
                  cursorColor: context.colors.primary,
                  cursorWidth: 2,
                  style: RegisterPageStyles.inputText,
                  minLines: 1,
                  maxLines: 1,
                  maxLength: 20,
                  buildCounter:
                      (
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
