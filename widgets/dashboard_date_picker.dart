import 'package:ehealth/dashboard_v2/dashboard_v2.dart';
import 'package:ehealth/util/util.dart';
import 'package:ehealth/widget/date_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:ehealth/app_localization.dart';

class DashboardDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProgressDialog dialog = ProgressDialog(context, isDismissible: false)
      ..style(message: AppLocalization.of(context).translate("loading"));
    return BlocConsumer<DashboardV2Cubit, DashboardV2State>(
      listenWhen: (pre, cur) => pre.queryProgress != cur.queryProgress,
      listener: (context, state) async {
        if (state.queryProgress == QueryProgress.inProgress) {
          await dialog.show();
        } else if (state.queryProgress == QueryProgress.done) {
          await dialog.hide();
        }
      },
      buildWhen: (pre, cur) => pre.query != cur.query,
      builder: (context, state) {
        return DateSelector(
          key: Key('dashboard_date_selector_widget'),
          handleTap: () async {
            final query = await showDatePicker(
              context: context,
              initialDate: state.query,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (query != null) {
              context.read<DashboardV2Cubit>().getDataAt(query: query);
            }
          },
          handleLeftTap: () => context
              .read<DashboardV2Cubit>()
              .getDataAt(query: state.query.previousDay),
          handleRightTap: () => context
              .read<DashboardV2Cubit>()
              .getDataAt(query: state.query.nextDay),
          label: state.query.asText,
        );
      },
    );
  }
}
