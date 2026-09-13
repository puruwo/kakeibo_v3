import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart'
    as year_service;
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';

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

  Future<void> _onResetToCurrent() async {
    final now = ref.read(systemDatetimeNotifierProvider);
    if (widget.mode == AppYearMonthPickerMode.yearMonth) {
      // nowが属する月度の開始月・年を使って選択状態を更新する
      // now.monthを直接使うと集計開始日をまたいだ場合に1月度ずれるため
      final currentPeriod =
          await ref.read(monthPeriodServiceProvider).fetchMonthPeriod(now);
      final start = currentPeriod.startDatetime;
      if (!mounted) return;
      setState(() {
        _selectedYear = start.year.clamp(widget.minYear, widget.maxYear);
        _selectedMonth = start.month;
      });
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _monthController.animateToItem(
        _selectedMonth - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // nowが属する年度の開始年を使って選択状態を更新する
      // now.yearを直接使うと集計開始月をまたいだ場合に1年度ずれるため
      final currentPeriod = await ref
          .read(year_service.yearPeriodServiceProvider)
          .fetchYearPeriod(now);
      if (!mounted) return;
      setState(() {
        _selectedYear =
            currentPeriod.startDatetime.year.clamp(widget.minYear, widget.maxYear);
      });
      _yearController.animateToItem(
        _selectedYear - widget.minYear,
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
          // 背景タップ層（暗幕。ボトムシートと同じ黒54%。KP-022）
          Positioned.fill(
            child: GestureDetector(
              onTap: () => widget.onClose(null),
              child: Container(color: context.colors.scrim),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      _buildPanel(),
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

  // 見出し・ドラム・ボタンを1枚のパネルにまとめる（KP-022 案B）。
  // CardContainer の地（cardSurface）はダークで半透明になり暗幕越しに下の画面が透けるため、
  // 形（角丸18＋1px枠）だけカードに揃え、地は不透明の surfaceElevated2 にする
  Widget _buildPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated2,
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: appCardRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: AppSpacing.sm),
          _buildPickerSection(),
          const SizedBox(height: AppSpacing.md),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // 入力欄の両脇に置く内側の操作なので枠なし・Tint 地（ボタンルール §5。KP-005 のステッパーと同じ）。
        // 選択範囲の端では onTap: null で非活性にする（ボタンルール §3）
        IconOnlyButton(
          key: const ValueKey('year_month_picker_previous'),
          icon: Icons.chevron_left_rounded,
          bordered: false,
          iconSize: 23,
          backgroundColor: context.colors.primaryTint,
          iconColor: context.colors.primary,
          onTap: _canShiftPrevious ? _onShiftPrevious : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatHeaderTitle(),
                style: context.textStyles.pageHeaderSubNumeric,
              ),
              const SizedBox(height: 2),
              Text(
                _formatRange(),
                style: context.textStyles.pageHeaderNumeric,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconOnlyButton(
          key: const ValueKey('year_month_picker_next'),
          icon: Icons.chevron_right_rounded,
          bordered: false,
          iconSize: 23,
          backgroundColor: context.colors.primaryTint,
          iconColor: context.colors.primary,
          onTap: _canShiftNext ? _onShiftNext : null,
        ),
      ],
    );
  }

  Widget _buildPickerSection() {
    return SizedBox(
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
              child: Text(
                _formatYearItem(y),
                style: context.textStyles.pageHeaderNumeric,
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
      selectionOverlay: _buildSelectionOverlay(),
      onSelectedItemChanged: (index) {
        _onPickerChanged(month: index + 1);
      },
      children: List.generate(
        12,
        (i) => Center(
          child: Text('${i + 1}月度', style: context.textStyles.pageHeaderNumeric),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        // 選択中の行の帯。非活性色（disabled）の流用をやめ、無彩色の塗りにする（KP-022）
        color: context.colors.fillTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // 並列2ボタン: 左 Secondary・右 Primary（ボタンルール §4。KP-022 で CupertinoButton から置換）
  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: MainButton(
            buttonType: ButtonColorType.secondary,
            onPressed: _onResetToCurrent,
            buttonText: widget.mode == AppYearMonthPickerMode.yearMonth
                ? '今月度に戻す'
                : '今年度に戻す',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MainButton(
            buttonType: ButtonColorType.main,
            onPressed: _onConfirm,
            // main ボタンの文字色は primary なのでアイコンも揃える
            icon: Icon(
              Icons.check_rounded,
              size: 18,
              color: context.colors.primary,
            ),
            buttonText: '適用',
          ),
        ),
      ],
    );
  }
}
