import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 記録モーダル（register_page）専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class RegisterPageStyles {
  RegisterPageStyles._();

  // ==========================================================================
  // 入力フィールド
  // ==========================================================================

  /// プレースホルダー・ラベル類（「メモを入力」「予算」「支払い頻度」等）
  static final TextStyle placeHolder = AppTypeScale.noto14w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 一般入力テキスト（メモ・拠出元・頻度の表示）
  static final TextStyle inputText = AppTypeScale.noto15w500.copyWith(
    color: AppColorsDark.text,
    height: 1.0,
  );

  // ==========================================================================
  // 金額表示（大きなフォント）
  // ==========================================================================

  /// 金額入力フィールド（¥42,000）
  static final TextStyle priceInput = AppTypeScale.sfUi42w700.copyWith(
    color: AppColorsDark.text,
    height: 1.0,
  );

  /// 未確定金額表示（---）
  static final TextStyle priceUnconfirmed = AppTypeScale.sfUi42w700.copyWith(
    color: AppColorsDark.textSecondary,
    height: 1.0,
  );

  /// 円記号（¥）。支出／収入で色が変わる
  static TextStyle yenSymbol(Color color) =>
      AppTypeScale.sfUi32w700.copyWith(color: color);

  // ==========================================================================
  // ピル・ボタン
  // ==========================================================================

  /// 種別ピル（支出／収入）のラベル。選択状態で色が変わる
  static TextStyle pillLabel(Color color) =>
      AppTypeScale.noto16w600.copyWith(color: color, height: 1.0);

  // ==========================================================================
  // カテゴリーエリア
  // ==========================================================================

  /// カテゴリーアイコン下のラベル（「食費」「交通費」等）
  static final TextStyle categoryLabel = AppTypeScale.noto13w500.copyWith(
    color: AppColorsDark.text,
  );

  /// 「アイコンを並べ替える」リンク
  static final TextStyle rearrangeLink = AppTypeScale.noto16w600.copyWith(
    color: AppColorsDark.textSecondary,
  );

  // ==========================================================================
  // アイコン並べ替えページ
  // ==========================================================================

  /// アイコン並べ替えページの説明文
  static final TextStyle iconRearrangeDescription = AppTypeScale.noto14w500
      .copyWith(color: AppColorsDark.textSecondary);
}
