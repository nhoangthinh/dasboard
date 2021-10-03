import 'package:ehealth/heart_rate/heart_rate.dart';
import 'package:ehealth/blood_pressure/blood_pressure.dart';
import 'package:ehealth/hrv/hrv.dart';
import 'package:ehealth/ecg/ecg.dart';
import 'package:ehealth/spo2/spo2.dart';
import 'package:ehealth/sleep/sleep.dart';
import 'package:ehealth/weight/weight.dart';
import 'package:ehealth/steps/steps.dart';
import 'package:ehealth/caring_dashboard/medical_remider/cubit/cc_reminder_cubit.dart';
import 'package:ehealth/caring_dashboard/patients/caring_dashboard.dart';
import 'package:ehealth/core/base/import/base_import_components.dart';
import 'package:ehealth/emergency_dashboard/medical_remider/cubit/emc_reminder_cubit.dart';
import 'package:ehealth/emergency_dashboard/patients/cubit/emc_dashboard_cubit.dart';
import 'package:ehealth/watch_stream/watch_stream.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veepoo_sdk/model/origin_v3_data.dart';
import 'package:veepoo_sdk/veepoo_sdk.dart';
import 'package:veepoo_sdk/model/sleep_data.dart';

part 'dashboard_v2_state.dart';

class DashboardV2Cubit extends Cubit<DashboardV2State> {
  DashboardV2Cubit() : super(DashboardV2State(query: DateTime.now()));

  HeartRateCubit heartRateCubit;
  BloodPressureCubit bloodPressureCubit;
  HrvCubit hrvCubit;
  EcgCubit ecgCubit;
  Spo2Cubit spo2Cubit;
  Sleep24hCubit sleepCubit;
  WeightCubit weightCubit;
  StepsCubit stepsCubit;

  void injectDependencies({
    HeartRateCubit heartRateCubit,
    BloodPressureCubit bloodPressureCubit,
    HrvCubit hrvCubit,
    EcgCubit ecgCubit,
    Spo2Cubit spo2Cubit,
    Sleep24hCubit sleepCubit,
    WeightCubit weightCubit,
    StepsCubit stepsCubit,
  }) {
    this.heartRateCubit = heartRateCubit;
    this.bloodPressureCubit = bloodPressureCubit;
    this.hrvCubit = hrvCubit;
    this.ecgCubit = ecgCubit;
    this.spo2Cubit = spo2Cubit;
    this.sleepCubit = sleepCubit;
    this.weightCubit = weightCubit;
    this.stepsCubit = stepsCubit;
  }

  void switchViewMode() => state.viewMode == ViewMode.COLLAPSED
      ? emit(state.copyWith(viewMode: ViewMode.EXPANDED))
      : emit(state.copyWith(viewMode: ViewMode.COLLAPSED));

  Future<void> pullRefresh([Function refreshCompleted]) async {
    try {
      final isConnected =
          await VeepooSdk.isConnected().timeout(const Duration(seconds: 15));
      if (isConnected) {
        OriginV3Data originV3Data = await VeepooSdk.readOrigin3Data()
            .timeout(const Duration(minutes: 3));
        List<SleepData> sleeps = await VeepooSdk.readSleepData(watchDay: 3)
            .timeout(const Duration(minutes: 4));
        SleepStream.instance.sleepChanged(Sleep24hStreamData.empty
            .copyWith(sleepData: sleeps, isEmpty: false));
        if (originV3Data != null) {
          HrStream.instance.sink(
              HrStreamData.empty.copyWith(data: originV3Data.originData3s));
          BpStream.instance.sink(BpStreamData.empty
              .copyWith(data: originV3Data.originHalfHourData));
          HrvStream.instance.sink(
              HrvStreamData.empty.copyWith(data: originV3Data.hrvOriginData));
          Spo2Stream.instance.sink(Spo2StreamData.empty
              .copyWith(data: originV3Data.spo2hOriginData));
          StepStream.instance.sink(
              StepStreamData.empty.copyWith(data: originV3Data.originData3s));
          emit(state.copyWith(query: DateTime.now()));
        }
      }
      FirebaseLogger().log("pull_refresh_end", "");
    } catch (error) {
      if (Platform.isAndroid && error is TimeoutException) {
        final duration = error.duration.inMinutes.toInt();
        if (duration == 4) {
          await VeepooSdk.setCompletedReadSleepData();
        } else if (duration == 3) {
          await VeepooSdk.setCompletedReadOriginData();
        }
      }
      FirebaseLogger().log("pull_refresh_error", error.toString());
    }
    if (refreshCompleted != null) {
      refreshCompleted();
    }
  }

  Future<void> getDataAt(
      {DateTime query, Function onSuccess, Function onFailure}) async {
    try {
      emit(state.copyWith(queryProgress: QueryProgress.inProgress));
      var futures = <Future>[];
      futures.add(heartRateCubit.getDataAt(query: query));
      futures.add(bloodPressureCubit.getDataAt(query: query));
      futures.add(hrvCubit.getDataAt(query: query));
      futures.add(ecgCubit.getDataAt(query: query));
      futures.add(spo2Cubit.getDataAt(query: query));
      futures.add(sleepCubit.getDataAt(query: query));
      futures.add(weightCubit.getDataAt(query: query));
      futures.add(stepsCubit.getDataAt(query: query));
      await Future.wait(futures);
      await Future.delayed(Duration(milliseconds: 210));
      emit(state.copyWith(query: query, queryProgress: QueryProgress.done));
      if (onSuccess != null) onSuccess();
    } catch (error) {
      if (onFailure != null) onFailure(error);
    }
  }

  Future<void> hrCurrentQuery() async =>
      await heartRateCubit.getDataAt(query: state.query);

  Future<void> bpCurrentQuery() async =>
      await bloodPressureCubit.getDataAt(query: state.query);

  Future<void> hrvCurrentQuery() async =>
      await hrvCubit.getDataAt(query: state.query);

  Future<void> spo2CurrentQuery() async =>
      await spo2Cubit.getDataAt(query: state.query);

  Future<void> sleepCurrentQuery() async =>
      await sleepCubit.getDataAt(query: state.query);

  Future<void> stepCurrentQuery() async =>
      await stepsCubit.getDataAt(query: state.query);

  void onChangeDashboard(int type) {
    switch (type) {
      case 0:
        break;
      case 1:
        onFetchDataEMC();
        break;
      case 2:
        onFetchDataCC();
        break;
      default:
        break;
    }
    emit(state.copyWith(typeDashboard: type));
  }

  Future<void> onFetchDataEMC() async {
    var futures = <Future>[];
    futures.add(Get.context.read<EmcDashboardCubit>().init());
    futures.add(Get.context.read<EmcReminderCubit>().init());
    await Future.wait(futures);
  }

  Future<void> onFetchDataCC() async {
    var futures = <Future>[];
    futures.add(Get.context.read<CcDashboardCubit>().init());
    futures.add(Get.context.read<CcReminderCubit>().init());
    await Future.wait(futures);
  }
}
