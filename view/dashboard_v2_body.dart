import 'package:ehealth/app_localization.dart';
import 'package:ehealth/caring_dashboard/patients/view/view.dart';
import 'package:ehealth/core/base/base_constant.dart';
import 'package:ehealth/core/base/import/base_import_components.dart';
import 'package:ehealth/dashboard_v2/dashboard_v2.dart';
import 'package:ehealth/emergency_dashboard/patients/view/emergency_dashboard_page.dart';
import 'package:ehealth/heart_rate/heart_rate.dart';
import 'package:ehealth/blood_pressure/blood_pressure.dart';
import 'package:ehealth/spo2/spo2.dart';
import 'package:ehealth/hrv/hrv.dart';
import 'package:ehealth/ecg/ecg.dart';
import 'package:ehealth/sleep/sleep.dart';
import 'package:ehealth/steps/steps.dart';
import 'package:ehealth/share_screen_shot/share_screen_shot.dart';
import 'package:ehealth/temperature/widget/temperature_card.dart';
import 'package:ehealth/weight/weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:veepoo_sdk/veepoo_sdk.dart';

class DashboardV2Body extends StatefulWidget {
  @override
  DashboardV2BodyState createState() => DashboardV2BodyState();
}

class DashboardV2BodyState extends State<DashboardV2Body>
    with AutomaticKeepAliveClientMixin<DashboardV2Body> {
  @override
  bool get wantKeepAlive => true;
  RefreshController _refreshController;

  ScreenshotController _screenshotController;

  @override
  void initState() {
    _screenshotController = ScreenshotController();
    final prefs = Get.find<SharedPreferences>();
    final _initialRefresh =
        prefs.getBool(Constant.INITIAL_REFRESH_KEY) ?? false;
    _refreshController = RefreshController(initialRefresh: _initialRefresh);
    prefs.remove(Constant.INITIAL_REFRESH_KEY);
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                DashboardAppBarWidget(
                  onSharePressed: () => shareScreenShot(context),
                  onConnectCallback: () => _refreshController.requestRefresh(),
                ),
                ListDashboardWidget(),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown:
                        context.read<DashboardV2Cubit>().state.isRefreshdable,
                    enablePullUp: false,
                    header: ClassicHeader(
                        refreshingText:
                            AppLocalization.of(context).translate("refreshing"),
                        releaseText: AppLocalization.of(context)
                            .translate("can_refresh"),
                        canTwoLevelText: AppLocalization.of(context)
                            .translate("can_two_level"),
                        completeText: AppLocalization.of(context)
                            .translate("refresh_complete"),
                        failedText: AppLocalization.of(context)
                            .translate("refresh_failed"),
                        idleText: AppLocalization.of(context)
                            .translate("idle_refresh")),
                    controller: _refreshController,
                    onRefresh: () async {
                      bool _isConnected = await VeepooSdk.isConnected()
                          .timeout(Duration(seconds: 10));
                      if (!_isConnected) {
                        _refreshController.refreshFailed();
                      } else {
                        context.read<DashboardV2Cubit>().pullRefresh(
                          () {
                            if (_refreshController.isRefresh) {
                              _refreshController.refreshCompleted();
                            }
                          },
                        );
                      }
                    },
                    onLoading: () {},
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Screenshot(
                        controller: _screenshotController,
                        child: _DashboardBody(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          DraggableSosButton(),
        ],
      ),
    );
  }

  Future<void> shareScreenShot(BuildContext context) async {
    final uInt8List = await _screenshotController.capture();
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/${Random().nextInt(1000) + 16777216}.png');
    await file.writeAsBytes(uInt8List);
    Get.toNamed(ShareScreenShot.routeName, arguments: file);
  }
}

class _DashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardV2Cubit, DashboardV2State>(
      buildWhen: (pre, cur) => pre.typeDashboard != cur.typeDashboard,
      builder: (context, state) {
        return Column(
          children: [
            Visibility(
              visible: state.typeDashboard == 0,
              child: Column(
                children: [
                  Container(color: Colors.white, child: HealthSliderWidget()),
                  const SizedBox(height: 24.0),
                  _SwitchViewMode(),
                  const SizedBox(height: 24.0),
                  HeartRateCard(),
                  const SizedBox(height: 16),
                  if (VisibleManagement.isVisibleTemperate) TemperatureCard(),
                  if (VisibleManagement.isVisibleTemperate)
                    const SizedBox(height: 16),
                  BloodPressureCard(),
                  const SizedBox(height: 16),
                  HrvCard(),
                  const SizedBox(height: 16),
                  Spo2Card(),
                  const SizedBox(height: 16),
                  EcgCard(),
                  const SizedBox(height: 16),
                  Sleep24hCard(),
                  const SizedBox(height: 16),
                  if (VisibleManagement.isVisibleWeight) WeightCard(),
                  if (VisibleManagement.isVisibleWeight)
                    const SizedBox(height: 16),
                  StepsCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Visibility(
              visible: state.typeDashboard == 1,
              child: EmergencyDashboardPage(),
            ),
            Visibility(
              visible: state.typeDashboard == 2,
              child: CaringDashboardPage(),
            )
          ],
        );
      },
    );
  }
}

class _SwitchViewMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardV2Cubit, DashboardV2State>(
      buildWhen: (previous, current) => previous.viewMode != current.viewMode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context).translate("patient_vital_index"),
                style: TextStyle(
                  fontFamily: Constant.APP_FONT_FAMILY,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => context.read<DashboardV2Cubit>().switchViewMode(),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Image.asset(
                          state.viewMode == ViewMode.COLLAPSED
                              ? "assets/icon/ic_expand_tint.png"
                              : "assets/icon/ic_collapse_tint.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalization.of(context).translate(
                          state.viewMode == ViewMode.COLLAPSED
                              ? "expand_all"
                              : "collapse_all"),
                      style: TextStyle(
                        fontFamily: Constant.APP_FONT_FAMILY,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: const Color(0xFF6CBE1B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
