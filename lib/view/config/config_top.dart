import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/export/export_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

class ConfigTop extends ConsumerWidget {
  const ConfigTop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '設定画面',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.pageHeaderText,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: MyColors.tirtiarySystemfill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  AppInkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // 設定画面からエクスポートを実行
                      ref.read(exportProvider).when(
                          data: (data) => null,
                          error: (e, _) => null,
                          loading: () =>
                              const Center(child: CircularProgressIndicator()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '入力履歴をエクスポートする',
                              style: AppTextStyles.oneLineButtonText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
