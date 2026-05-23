import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';

/// AppYearMonthPicker の表示モード
enum AppYearMonthPickerMode {
  /// 年・月の2列表示（月度選択用）
  yearMonth,

  /// 年のみ1列表示（年度選択用）
  year,
}

/// 年月（または年）を選択するドラムロール式ボトムシートを表示する
///
/// 戻り値:
/// - 確定: mode==yearMonth → DateTime(year, month, 1)、mode==year → DateTime(year, 1, 1)
/// - キャンセル / 外タップ: null
Future<DateTime?> showAppYearMonthPicker({
  required BuildContext context,
  required AppYearMonthPickerMode mode,
  required DateTime initialDateTime,
  int? minYear,
  int? maxYear,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => AppYearMonthPicker(
      mode: mode,
      initialDateTime: initialDateTime,
      minYear: minYear ?? 2000,
      maxYear: maxYear ?? DateTime.now().year + 10,
    ),
  );
}

/// 年月または年を選択するドラムロール式ピッカー
///
/// [showAppYearMonthPicker] 経由で使用する。
/// 確定時は Navigator.pop(context, DateTime) で結果を返す。
class AppYearMonthPicker extends StatefulWidget {
  const AppYearMonthPicker({
    super.key,
    required this.mode,
    required this.initialDateTime,
    required this.minYear,
    required this.maxYear,
  });

  final AppYearMonthPickerMode mode;
  final DateTime initialDateTime;
  final int minYear;
  final int maxYear;

  @override
  State<AppYearMonthPicker> createState() => _AppYearMonthPickerState();
}

class _AppYearMonthPickerState extends State<AppYearMonthPicker> {
  late int _selectedYear;
  late int _selectedMonth;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  @override
  void initState() {
    super.initState();
    _selectedYear =
        widget.initialDateTime.year.clamp(widget.minYear, widget.maxYear);
    _selectedMonth = widget.initialDateTime.month;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - widget.minYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final result = widget.mode == AppYearMonthPickerMode.yearMonth
        ? DateTime(_selectedYear, _selectedMonth, 1)
        : DateTime(_selectedYear);
    Navigator.of(context).pop(result);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          color: MyColors.tirtiarySystemBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButtonBar(),
              Divider(
                color: MyColors.separater,
                height: 0.5,
                thickness: 0.5,
              ),
              SizedBox(
                height: 216,
                child: widget.mode == AppYearMonthPickerMode.yearMonth
                    ? Row(
                        children: [
                          Expanded(child: _buildYearPicker()),
                          Expanded(child: _buildMonthPicker()),
                        ],
                      )
                    : Center(
                        child: SizedBox(
                          width: 160,
                          child: _buildYearPicker(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonBar() {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _onCancel,
            child: Text(
              'キャンセル',
              style: AppTextStyles.secondaryButtonText.copyWith(
                color: MyColors.secondaryLabel,
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _onConfirm,
            child: Text(
              '完了',
              style: AppTextStyles.mainButtonText.copyWith(
                color: MyColors.themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker() {
    final years = List.generate(
      widget.maxYear - widget.minYear + 1,
      (i) => widget.minYear + i,
    );

    return CupertinoPicker(
      scrollController: _yearController,
      itemExtent: 38.0,
      magnification: 1.1,
      useMagnifier: true,
      diameterRatio: 1.2,
      backgroundColor: Colors.transparent,
      onSelectedItemChanged: (index) {
        _selectedYear = years[index];
      },
      children: years
          .map(
            (year) => Center(
              child: Text(
                '$year年',
                style: AppTextStyles.pageHeaderText,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthPicker() {
    return CupertinoPicker(
      scrollController: _monthController,
      itemExtent: 38.0,
      magnification: 1.1,
      useMagnifier: true,
      diameterRatio: 1.2,
      backgroundColor: Colors.transparent,
      onSelectedItemChanged: (index) {
        _selectedMonth = index + 1;
      },
      children: List.generate(
        12,
        (i) => Center(
          child: Text(
            '${i + 1}月',
            style: AppTextStyles.pageHeaderText,
          ),
        ),
      ),
    );
  }
}
