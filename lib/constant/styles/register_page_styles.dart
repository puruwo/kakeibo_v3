import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 記録モーダル（register_page）専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class RegisterPageStyles {
  /// [colors] は現在のテーマの色トークン。通常は `context.registerStyles` 経由で受け取る
  const RegisterPageStyles(this.colors);

  /// 役割スタイルの色の出どころ（ライト／ダークで値が変わる）
  final AppColors colors;

  /// context 無しに使う固定インスタンス（テストの期待値・Painter への注入元）
  static const RegisterPageStyles light = RegisterPageStyles(AppColors.light);
  static const RegisterPageStyles dark = RegisterPageStyles(AppColors.dark);

  // ==========================================================================
  // 入力フィールド
  // ==========================================================================

  /// プレースホルダー・ラベル類（「メモを入力」「予算」「支払い頻度」等）
  TextStyle get placeHolder =>
      AppTypeScale.noto14w500.copyWith(color: colors.textSecondary);

  /// 一般入力テキスト（メモ・拠出元・頻度の表示）
  TextStyle get inputText =>
      AppTypeScale.noto15w500.copyWith(color: colors.text, height: 1.0);

  // ==========================================================================
  // 金額表示（大きなフォント）
  // ==========================================================================

  /// 金額入力フィールド（¥42,000）
  TextStyle get priceInput =>
      AppTypeScale.sfUi42w700.copyWith(color: colors.text, height: 1.0);

  /// 未確定金額表示（---）
  TextStyle get priceUnconfirmed => AppTypeScale.sfUi42w700.copyWith(
    color: colors.textSecondary,
    height: 1.0,
  );

  /// 円記号（¥）。支出／収入で色が変わる。金額と下端を揃えるため行高を詰める
  static TextStyle yenSymbol(Color color) =>
      AppTypeScale.sfUi32w700.copyWith(color: color, height: 1.0);

  // ==========================================================================
  // ピル・ボタン
  // ==========================================================================

  /// 種別ピル（支出／収入）のラベル。選択状態で色が変わる
  static TextStyle pillLabel(Color color) =>
      AppTypeScale.noto16w600.copyWith(color: color, height: 1.0);

  // ==========================================================================
  // カテゴリーエリア
  // ==========================================================================

  /// カテゴリーアイコン下のラベル（「食費」「交通費」等。未選択状態が無いグリッド用）
  TextStyle get categoryLabel =>
      AppTypeScale.noto13w500.copyWith(color: colors.text);

  /// カテゴリー選択グリッドの選択中ラベル
  TextStyle get categoryLabelSelected =>
      AppTypeScale.noto13w700.copyWith(color: colors.text);

  /// カテゴリー選択グリッドの未選択ラベル
  TextStyle get categoryLabelUnselected =>
      AppTypeScale.noto13w400.copyWith(color: colors.textSecondary);

  /// 「アイコンを並べ替える」リンク
  TextStyle get rearrangeLink =>
      AppTypeScale.noto16w600.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // アイコン並べ替えページ
  // ==========================================================================

  /// アイコン並べ替えページの説明文
  TextStyle get iconRearrangeDescription =>
      AppTypeScale.noto14w500.copyWith(color: colors.textSecondary);
}

/// BuildContext から現在のテーマの記録モーダル専用の役割スタイルを取る（KP-013）
extension RegisterPageStylesX on BuildContext {
  RegisterPageStyles get registerStyles => RegisterPageStyles(colors);
}
