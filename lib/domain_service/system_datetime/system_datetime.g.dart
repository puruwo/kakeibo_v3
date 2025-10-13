// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_datetime.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$systemDatetimeNotifierHash() =>
    r'd81fc3a699206b0c582236034982e316146cdcd1';

/// アプリ立ち上げ時点での日時を提供するプロバイダ
/// アプリ起動中は常に同じ日時を返す
/// アプリ内ではこのプロバイダを基準にして日付を扱う
///
/// Copied from [SystemDatetimeNotifier].
@ProviderFor(SystemDatetimeNotifier)
final systemDatetimeNotifierProvider =
    NotifierProvider<SystemDatetimeNotifier, DateTime>.internal(
  SystemDatetimeNotifier.new,
  name: r'systemDatetimeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemDatetimeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SystemDatetimeNotifier = Notifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
