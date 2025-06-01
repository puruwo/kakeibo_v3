// logger import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class ProviderLogger implements ProviderObserver {
  const ProviderLogger();

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    // famlyの時は、nameがnullになり、ロガーに出力されない
    if(provider.name == null) return;
    logger.i('[ADD${provider.name}: ${provider.describe}');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    // famlyの時は、nameがnullになり、ロガーに出力されない
    if(provider.name == null) return;
    logger.d('[DISPOSE]${provider.name}: ${provider.describe}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // famlyの時は、nameがnullになり、ロガーに出力されない
    if(provider.name == null) return;
    logger.i('''[UPDATE]${provider.name}: ${provider.describe}\n
    previous: $previousValue\n
    -> now: $newValue''');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // logger.e('[FAIL]: ${provider.describe}');
  }
}

extension _ProviderName on ProviderBase {
  String get describe => name ?? toString();
}
