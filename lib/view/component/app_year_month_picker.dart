import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart'
    as year_service;

/// AppYearMonthPicker の表示モード
enum AppYearMonthPickerMode {
  /// 年・月の2列表示（月度選択用）
  yearMonth,

  /// 年のみ1列表示（年度選択用）
  year,
}

/// AppBar 下にドロップダウン式オーバーレイで年月度／年度ピッカーを表示する。
///
/// 戻り値:
/// - 「適用」確定: yearMonth → DateTime(year, month, 1)、year → DateTime(year, 1, 1)
/// - 背景タップ: null
Future<DateTime?> showAppYearMonthPicker({
  required BuildContext context,
  required AppYearMonthPickerMode mode,
  required DateTime initialDateTime,
  int? minYear,
  int? maxYear,
}) async {
  final completer = Completer<DateTime?>();
  final overlayState = Overlay.of(context, rootOverlay: true);
  final appBarBottom =
      MediaQuery.of(context).padding.top + kToolbarHeight;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _AppYearMonthPickerOverlay(
      mode: mode,
      initialDateTime: initialDateTime,
      minYear: minYear ?? 2000,
      maxYear: maxYear ?? DateTime.now().year + 10,
      appBarBottom: appBarBottom,
      onClose: (result) {
        entry.remove();
        if (!completer.isCompleted) completer.complete(result);
      },
    ),
  );

  overlayState.insert(entry);
  return completer.future;
}

class _AppYearMonthPickerOverlay extends ConsumerStatefulWidget {
  const _AppYearMonthPickerOverlay({
    required this.mode,
    required this.initialDateTime,
    required this.minYear,
    required this.maxYear,
    required this.appBarBottom,
    required this.onClose,
  });

  final AppYearMonthPickerMode mode;
  final DateTime initialDateTime;
  final int minYear;
  final int maxYear;
  final double appBarBottom;
  final void Function(DateTime?) onClose;

  @override
  ConsumerState<_AppYearMonthPickerOverlay> createState() =>
      _AppYearMonthPickerOverlayState();
}

class _AppYearMonthPickerOverlayState
    extends ConsumerState<_AppYearMonthPickerOverlay>
    with SingleTickerProviderStateMixin {
  late int _selectedYear;
  late int _selectedMonth;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  PeriodValue? _period;
  // 年度モードのピッカー項目ラベル生成に使用
  int? _aggregationStartMonth;
  int? _aggregationStartDay;

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

    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animController);

    _animController.forward();
    _fetchPeriod();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchPeriod() async {
    try {
      // 年度モードのとき集計開始月・日を取得してピッカー項目ラベルに使用する
      if (widget.mode == AppYearMonthPickerMode.year &&
          _aggregationStartMonth == null) {
        final startMonth = await ref
            .read(aggregationStartMonthProvider)
            .fetchAggregationStartMonth();
        final startDay = await ref
            .read(aggregationStartDayProvider)
            .fetchAggregationStartDay();
        if (mounted) {
          setState(() {
            _aggregationStartMonth = startMonth.month;
            _aggregationStartDay = startDay.day;
          });
        }
      }
      final period = await _computePeriod(_selectedYear, _selectedMonth);
      if (mounted) {
        setState(() => _period = period);
      }
    } catch (_) {}
  }

  Future<PeriodValue> _computePeriod(int year, int month) async {
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      // 月の末日を渡すことで、集計開始日の設定に依存せず
      // 選んだ月を含む正しい月度の期間を取得する
      final lastDayOfMonth = DateTime(year, month + 1, 0);
      return ref
          .read(monthPeriodServiceProvider)
          .fetchMonthPeriod(lastDayOfMonth);
    } else {
      // 集計開始月・開始日を使った日付を渡すことで、
      // fetchYearPeriod が正しく選択年の年度期間を返す
      final startMonth = await ref
          .read(aggregationStartMonthProvider)
          .fetchAggregationStartMonth();
      final startDay = await ref
          .read(aggregationStartDayProvider)
          .fetchAggregationStartDay();
      return ref
          .read(year_service.yearPeriodServiceProvider)
          .fetchYearPeriod(DateTime(year, startMonth.month, startDay.day));
    }
  }

  void _onPickerChanged({int? year, int? month}) {
    setState(() {
      if (year != null) _selectedYear = year;
      if (month != null) _selectedMonth = month;
    });
    _fetchPeriod();
  }

  void _onShiftPrevious() {
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      var newYear = _selectedYear;
      var newMonth = _selectedMonth - 1;
      if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }
      if (newYear < widget.minYear) return;
      _selectedYear = newYear;
      _selectedMonth = newMonth;
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _monthController.animateToItem(
        _selectedMonth - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      if (_selectedYear <= widget.minYear) return;
      _selectedYear--;
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    setState(() {});
    _fetchPeriod();
  }

  void _onShiftNext() {
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      var newYear = _selectedYear;
      var newMonth = _selectedMonth + 1;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      }
      if (newYear > widget.maxYear) return;
      _selectedYear = newYear;
      _selectedMonth = newMonth;
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _monthController.animateToItem(
        _selectedMonth - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      if (_selectedYear >= widget.maxYear) return;
      _selectedYear++;
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    setState(() {});
    _fetchPeriod();
  }

  void _onResetToCurrent() {
    final now = ref.read(systemDatetimeNotifierProvider);
    final newYear = now.year.clamp(widget.minYear, widget.maxYear);
    final newMonth = now.month;
    setState(() {
      _selectedYear = newYear;
      _selectedMonth = newMonth;
    });
    _yearController.animateToItem(
      _selectedYear - widget.minYear,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      _monthController.animateToItem(
        _selectedMonth - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    _fetchPeriod();
  }

  void _onConfirm() {
    final result = widget.mode == AppYearMonthPickerMode.yearMonth
        // 月末日を渡すことで fetchMonthPeriod が必ず選択月の月度を返すようにする
        ? DateTime(_selectedYear, _selectedMonth + 1, 0)
        : DateTime(_selectedYear, 1, 1);
    widget.onClose(result);
  }

  String _formatHeaderTitle() {
    final period = _period;
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      // 集計開始日を含む月（期間のstartDatetime.month）を月度として表示
      if (period != null) {
        return '$_selectedYear年 ${period.startDatetime.month}月度';
      }
      return '$_selectedYear年 $_selectedMonth月度';
    } else {
      return '$_selectedYear年度';
    }
  }

  String _formatRange() {
    final period = _period;
    if (period == null) return '';
    final start = period.startDatetime;
    final end = period.endDatetime;
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      return '${start.month}/${start.day} - ${end.month}/${end.day}';
    } else {
      // 年度モード: yyyy/mm〜yyyy/mm 形式
      return '${start.year}/${start.month}〜${end.year}/${end.month}';
    }
  }

  bool get _canShiftPrevious {
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      if (_selectedMonth == 1) return _selectedYear > widget.minYear;
      return true;
    }
    return _selectedYear > widget.minYear;
  }

  bool get _canShiftNext {
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      if (_selectedMonth == 12) return _selectedYear < widget.maxYear;
      return true;
    }
    return _selectedYear < widget.maxYear;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 背景タップ層（半透明）
          Positioned.fill(
            child: GestureDetector(
              onTap: () => widget.onClose(null),
              child: Container(color: Colors.black.withValues(alpha: 0.75)),
            ),
          ),
          // ピッカー本体（AppBar直下にスライドイン）
          Positioned(
            top: widget.appBarBottom,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeaderCard(),
                      const SizedBox(height: 8),
                      _buildPickerSection(),
                      const SizedBox(height: 8),
                      _buildButtonRow(),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.tirtiarySystemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: _canShiftPrevious
                  ? MyColors.white
                  : MyColors.secondaryLabel,
            ),
            onPressed: _canShiftPrevious ? _onShiftPrevious : null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatHeaderTitle(),
                  style: AppTextStyles.pageHeaderSubText,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRange(),
                  style: AppTextStyles.pageHeaderText,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: _canShiftNext
                  ? MyColors.white
                  : MyColors.secondaryLabel,
            ),
            onPressed: _canShiftNext ? _onShiftNext : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSection() {
    return Container(
      height: 216,
      decoration: BoxDecoration(
        color: MyColors.tirtiarySystemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: widget.mode == AppYearMonthPickerMode.yearMonth
          ? Row(
              children: [
                Expanded(child: _buildYearPicker()),
                Expanded(child: _buildMonthPicker()),
              ],
            )
          : Center(
              child: SizedBox(
                width: 280,
                child: _buildYearPicker(),
              ),
            ),
    );
  }

  // 年度モードのピッカー項目ラベルを生成する
  // 年度モードのとき「$year年$startMonth月〜${endDate.year}年${endDate.month}月」形式、
  // 年月モードまたはロード中は「$year年」にフォールバックする
  String _formatYearItem(int year) {
    if (widget.mode != AppYearMonthPickerMode.year ||
        _aggregationStartMonth == null ||
        _aggregationStartDay == null) {
      return '$year年';
    }
    final startMonth = _aggregationStartMonth!;
    final startDay = _aggregationStartDay!;
    // DateTime補正で月跨ぎ・年跨ぎが解決される
    final endDate = DateTime(year + 1, startMonth, startDay - 1);
    return '$year年$startMonth月〜${endDate.year}年${endDate.month}月';
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
      selectionOverlay: _buildSelectionOverlay(),
      onSelectedItemChanged: (index) {
        _onPickerChanged(year: years[index]);
      },
      children: years
          .map(
            (y) => Center(
              child: Text(_formatYearItem(y), style: AppTextStyles.pageHeaderText),
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
      selectionOverlay: _buildSelectionOverlay(),
      onSelectedItemChanged: (index) {
        _onPickerChanged(month: index + 1);
      },
      children: List.generate(
        12,
        (i) => Center(
          child: Text('${i + 1}月度', style: AppTextStyles.pageHeaderText),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: MyColors.systemGray4.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            color: MyColors.systemGray4,
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: _onResetToCurrent,
            child: Text(
              widget.mode == AppYearMonthPickerMode.yearMonth
                  ? '今月度に戻す'
                  : '今年度に戻す',
              style: AppTextStyles.mainButtonText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CupertinoButton(
            color: MyColors.themeColor,
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: _onConfirm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, color: MyColors.white, size: 18),
                const SizedBox(width: 4),
                Text('適用', style: AppTextStyles.mainButtonText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
