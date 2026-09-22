import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_list_service.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_list_usecase.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_usecase.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/bulk_delete_page/bulk_delete_item_tile.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/history_list_skeleton.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// 支出・収入レコードをまとめて削除するページ（KP-031）
///
/// 遷移元の種別（[mode]）の全レコードを履歴タブと同じ日付見出し＋行で並べ、
/// 行タップで選択を切り替える。長押しした起点の行（[initialSelectedId]）は選択済みで開き、
/// その日付までスクロールする。フッターの「N件を削除」→ 確認 → 削除の後も一覧に留まる。
/// root Navigator に push する全画面（→ openBulkDeletePage）。
class BulkDeletePage extends ConsumerStatefulWidget {
  const BulkDeletePage({
    super.key,
    required this.mode,
    required this.initialSelectedId,
  });

  final BulkDeleteMode mode;

  /// 長押しした起点のレコード ID（開いた時点で選択済みにする）
  final int initialSelectedId;

  @override
  ConsumerState<BulkDeletePage> createState() => _BulkDeletePageState();
}

class _BulkDeletePageState extends ConsumerState<BulkDeletePage> {
  /// 選択中の ID。一覧に無い ID（削除済み等）は表示・件数に数えない
  late final Set<int> _selectedIds = {widget.initialSelectedId};

  final AutoScrollController _scrollController = AutoScrollController();

  /// 起点の行へのスクロールは最初にデータが揃ったとき1回だけ
  bool _scrolledToInitial = false;

  /// 削除の実行中（二重実行を防ぐためボタンと全選択を非活性にする）
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    // 日付見出し（yyyy年M月d日(E)）の日本語対応
    initializeDateFormatting();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(bulkDeleteListNotifierProvider(widget.mode));
    final groups = groupsAsync.valueOrNull ?? const <DailyTransactionGroup>[];
    final allIds = collectBulkDeleteRecordIds(groups);
    final selected = _selectedIds.intersection(allIds);
    final isAllSelected = allIds.isNotEmpty && selected.length == allIds.length;
    final leftsidePadding = context.leftsidePadding;

    _scheduleInitialScroll(groups);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(AppIcons.back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.mode.pageTitle,
          style: context.textStyles.pageHeaderText,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        actions: [
          _SelectAllAction(
            label: isAllSelected ? 'すべて解除' : 'すべて選択',
            onPressed: allIds.isEmpty || _deleting
                ? null
                : () => _toggleSelectAll(allIds, isAllSelected),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: groupsAsync.when(
              // 削除後の取り直しでスケルトンに戻さず、前の一覧を出したままにする
              skipLoadingOnReload: true,
              data: (groups) => groups.isEmpty
                  ? const _EmptyMessage()
                  : _buildList(groups, selected, leftsidePadding),
              error: (error, stackTrace) {
                logger.e('[FAIL] 一括削除の一覧の取得に失敗: $error');
                return const AppErrorState(message: 'データの取得に失敗しました');
              },
              loading: () => const HistoryListSkeleton(),
            ),
          ),
          _DeleteFooter(
            selectedCount: selected.length,
            onPressed: selected.isEmpty || _deleting
                ? null
                : () => _confirmAndDelete(selected),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<DailyTransactionGroup> groups,
    Set<int> selected,
    double leftsidePadding,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: groups.length + 1,
      itemBuilder: (context, index) {
        // リスト末尾のスペーサー
        if (index == groups.length) {
          return const SizedBox(height: AppSpacing.lg);
        }
        final group = groups[index];
        return AutoScrollTag(
          key: ValueKey(index),
          index: index,
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 日付ヘッダーの上スペース（履歴タブと同じ）
              const SizedBox(height: 13),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: leftsidePadding),
                    child: Text(
                      DateFormat('yyyy年M月d日(E)', 'ja_JP').format(group.date),
                      style: context.textStyles.listTileSectionTitle,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.25,
                height: 0.25,
                indent: leftsidePadding,
                endIndent: leftsidePadding,
                color: context.colors.separator,
              ),
              for (final expense in group.expenses)
                BulkDeleteItemTile.expense(
                  key: ValueKey('bulk-delete-expense-${expense.id}'),
                  value: expense,
                  isSelected: selected.contains(expense.id),
                  onTap: () => _toggle(expense.id),
                  leftsidePadding: leftsidePadding,
                ),
              for (final income in group.incomes)
                BulkDeleteItemTile.income(
                  key: ValueKey('bulk-delete-income-${income.id}'),
                  value: income,
                  isSelected: selected.contains(income.id),
                  onTap: () => _toggle(income.id),
                  leftsidePadding: leftsidePadding,
                ),
            ],
          ),
        );
      },
    );
  }

  void _toggle(int id) {
    if (_deleting) return;
    setState(() {
      if (!_selectedIds.remove(id)) {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(Set<int> allIds, bool isAllSelected) {
    setState(() {
      if (isAllSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(allIds);
      }
    });
  }

  /// 起点のレコードを含む日付グループまでスクロールする（最初のデータ到着時に1回）
  void _scheduleInitialScroll(List<DailyTransactionGroup> groups) {
    if (_scrolledToInitial || groups.isEmpty) return;
    _scrolledToInitial = true;

    final index = groups.indexWhere(
      (g) =>
          g.expenses.any((e) => e.id == widget.initialSelectedId) ||
          g.incomes.any((i) => i.id == widget.initialSelectedId),
    );
    if (index <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
    });
  }

  Future<void> _confirmAndDelete(Set<int> selected) async {
    final count = selected.length;
    // 非同期の後で context を使わないよう、先に解決しておく
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmationDialog(
      context,
      title: '$count件の記録を削除',
      message: '削除したデータは戻せません。\n本当に削除しますか？',
      confirmLabel: '削除する',
      cancelLabel: 'キャンセル',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref
          .read(bulkDeleteUsecaseProvider)
          .delete(mode: widget.mode, ids: selected.toList());
      if (!mounted) return;
      setState(() => _selectedIds.clear());
      SuccessSnackBar.show(messenger, message: '$count件を削除しました');
    } catch (e) {
      logger.e('[FAIL] 一括削除に失敗: $e');
      if (!mounted) return;
      // 失敗時は選択を保持したままにする（やり直せるように）
      FailureSnackBar.show(messenger, message: '削除に失敗しました');
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}

/// AppBar 右の「すべて選択／すべて解除」（文字アクション。非活性は textTertiary）
class _SelectAllAction extends StatelessWidget {
  const _SelectAllAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: context.textStyles.textButtonTextStyle.copyWith(
          color: enabled ? context.colors.primary : context.colors.textTertiary,
        ),
      ),
    );
  }
}

/// フッターの全幅 Destructive ボタン（0件は非活性で「削除」。カンバス C1）
class _DeleteFooter extends StatelessWidget {
  const _DeleteFooter({required this.selectedCount, required this.onPressed});

  final int selectedCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // root に push した全画面のためグロナビは無く、下部はセーフエリア基準（仕様 §3）
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        child: MainButton(
          buttonType: ButtonColorType.danger,
          iconData: AppIcons.delete,
          buttonText: selectedCount > 0 ? '$selectedCount件を削除' : '削除',
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// 0件の空状態（履歴タブと同じ1行テキスト。次アクションが無いため AppEmptyState は使わない）
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text('記録がまだありません', style: context.textStyles.listEmptyMessage),
        ),
      ],
    );
  }
}
