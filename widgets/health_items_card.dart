import 'package:ehealth/app_localization.dart';
import 'package:ehealth/connect_device/connect_device.dart';
import 'package:ehealth/core/base/base_constant.dart';
import 'package:ehealth/heart_rate/heart_rate.dart';
import 'package:ehealth/blood_pressure/blood_pressure.dart';
import 'package:ehealth/hrv/hrv.dart';
import 'package:ehealth/spo2/spo2.dart';
import 'package:ehealth/ecg/ecg.dart';
import 'package:ehealth/sleep/sleep.dart';
import 'package:ehealth/steps/steps.dart';
import 'package:ehealth/weight/view/weight_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HealthItemsCard extends StatefulWidget {
  @override
  _HealthItemsCardState createState() => _HealthItemsCardState();
}

class _HealthItemsCardState extends State<HealthItemsCard> {
  List<Widget> _listItem = [];
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    _listItem = [
      _HrQuickIcon(),
      _BpQuickIcon(),
      _HrvQuickIcon(),
      _Spo2QuickIcon(),
      _EcgQuickIcon(),
      _SleepQuickIcon(),
      _StepQuickIcon(),
      _WeightQuickIcon(),
    ];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectDeviceCubit, ConnectDeviceState>(
      buildWhen: (pre, cur) => pre.connectStatus != cur.connectStatus,
      builder: (context, state) {
        if (state.connectStatus == ConnectStatus.CONNECTED)
          return Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 10, 62, .05),
                  blurRadius: 15.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    reverse: false,
                    controller: _scrollController,
                    itemCount: _listItem.length,
                    itemBuilder: (_, int index) => _listItem[index],
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
              ],
            ),
          );
        return SizedBox();
      },
    );
  }
}

class _HrQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_hr_panel.png",
      name: "_hr_",
      onPressed: () => Get.toNamed(MeasureHrPage.routeName),
    );
  }
}

class _BpQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_bp_panel.png",
      name: "_bp_",
      onPressed: () => Get.toNamed(MeasureBpPage.routeName),
    );
  }
}

class _HrvQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_hrv_panel.png",
      name: "_hrv_",
      onPressed: () => Get.toNamed(HrvPage.routeName),
    );
  }
}

class _Spo2QuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_spo2_panel.png",
      name: "spo2_",
      onPressed: () => Get.toNamed(MeasureSpo2Page.routeName),
    );
  }
}

class _EcgQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_ecg_panel.png",
      name: "ecg_",
      onPressed: () => Get.toNamed(MeasureEcgPage.routeName),
    );
  }
}

class _SleepQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_sleep_panel.png",
      name: "sleep_",
      onPressed: () => Get.toNamed(Sleep24hPage.routeName),
    );
  }
}

class _StepQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_step_panel.png",
      name: "steps_",
      onPressed: () => Get.toNamed(StepsPage.routeName),
    );
  }
}

class _WeightQuickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HealthIcon(
      imagePath: "assets/icon/ic_weight_panel.png",
      name: "weight",
      onPressed: () => Get.toNamed(WeightPage.routeName),
    );
  }
}


class _HealthIcon extends StatelessWidget {
  _HealthIcon({
    this.imagePath,
    this.name,
    this.onPressed,
  });

  final String imagePath;
  final String name;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalization.of(context).translate(name),
              style: TextStyle(
                fontFamily: Constant.APP_FONT_FAMILY,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
