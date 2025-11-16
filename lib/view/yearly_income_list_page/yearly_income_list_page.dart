import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view/yearly_income_list_page/income_graph_area.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_area.dart';

class YearlyIncomeListPage extends ConsumerWidget {
  const YearlyIncomeListPage({
    super.key,
    required this.dateScope,
  });

  final DateScopeEntity dateScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '収入一覧',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              color: MyColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,16,16,0),
              child: IncomeGraphArea(
                dateScope: dateScope,
              ),
            ),
            Expanded(
              child: YearlyIncomeListArea(
                dateScope: dateScope,
              ),
            )
          ],
        ));
  }
}
