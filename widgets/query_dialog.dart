import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ehealth/core/base/base_constant.dart';
import 'package:flutter/material.dart';

import '../../app_localization.dart';

class QueryDialog {
  static final QueryDialog _singleton = QueryDialog._internal();

  factory QueryDialog() => _singleton;

  QueryDialog._internal();

  static BuildContext context;
  static bool isShowing = false;

  static setCurrentContext(BuildContext context) {
    if (QueryDialog.context == null) {
      QueryDialog.context = context;
    }
  }

  static AwesomeDialog loadingDialog = AwesomeDialog(
    context: QueryDialog.context,
    dialogType: DialogType.NO_HEADER,
    headerAnimationLoop: false,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    autoHide: const Duration(seconds: 10),
    body: Container(
      width: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 30),
            Text(
              AppLocalization.of(QueryDialog.context).translate("loading_"),
              style: TextStyle(
                color: const Color(0xFF15A4DD),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: Constant.APP_FONT_FAMILY,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static Future<void> show() async {
    if (QueryDialog.isShowing) await QueryDialog.dismiss();
    QueryDialog.isShowing = true;
    await QueryDialog.loadingDialog.show();
  }

  static Future<void> dismiss() async {
    if (QueryDialog.context == null ||
        !QueryDialog.isShowing ||
        QueryDialog.loadingDialog == null) return;
    QueryDialog.loadingDialog.isDissmisedBySystem = false;
    await QueryDialog.loadingDialog.dissmiss();
    QueryDialog.isShowing = false;
    QueryDialog.context = null;
  }
}
