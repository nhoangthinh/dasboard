import 'package:ehealth/connect_device/connect_device.dart';
import 'package:ehealth/core/base/import/base_import_components.dart';
import 'package:ehealth/core/model/user_profile_model.dart';
import 'package:ehealth/dashboard_v2/dashboard_v2.dart';
import 'package:ehealth/view/base/settings/account_page.dart';
import 'package:ehealth/widget/widget_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardAppBarWidget extends StatelessWidget {
  const DashboardAppBarWidget({
    this.onSharePressed,
    this.onConnectCallback,
  });

  final Function onSharePressed;
  final Function onConnectCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 10, 62, 0.05),
            blurRadius: 20.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 89,
            child: AspectRatio(
              aspectRatio: 89 / 36,
              child: Image.asset(
                "assets/images/img_logo_mcare.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (onSharePressed != null) onSharePressed();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 24.0),
                  child: SizedBox(
                    width: 32,
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.asset(
                        "assets/icon/ic_tab_bar_share.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              _WatchButton(onConnectCallback),
              _Avatar(),
            ],
          )
        ],
      ),
    );
  }
}

class _WatchButton extends StatefulWidget {
  _WatchButton(this.onConnectCallback);

  final Function onConnectCallback;

  @override
  __WatchButtonState createState() => __WatchButtonState();
}

class __WatchButtonState extends State<_WatchButton> {
  bool isBlinking = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectDeviceCubit, ConnectDeviceState>(
      buildWhen: (pre, cur) => shouldRebuild(pre, cur),
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(ConnectDevicePage.routeName).then(
              (value) {
                if (value != null && value == 1) {
                  widget.onConnectCallback();
                }
              },
            );
          },
          child: isBlinking
              ? WatchAnimatedWidget()
              : Container(
                  margin: const EdgeInsets.only(right: 24.0),
                  child: SizedBox(
                    width: 32,
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.asset(
                        state.connectStatus == ConnectStatus.CONNECTED
                            ? "assets/icon/ic_action_bar_device_connect.png"
                            : "assets/icon/ic_action_bar_device_disconnect.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  bool shouldRebuild(ConnectDeviceState oldState, ConnectDeviceState newState) {
    if (oldState.connectStatus == ConnectStatus.LOST_CONNECT &&
        newState.connectStatus == ConnectStatus.CONNECTED) {
      isBlinking = true;
    } else {
      isBlinking = false;
    }
    return !newState.isInBackground;
  }
}

class _Avatar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> {
  bool _isReload = false;

  @override
  void initState() {
    super.initState();
    _isReload = false;
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      _isReload = !_isReload;
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Route route = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AccountPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 400),
        );
        Navigator.push(context, route).then(onGoBack);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 0),
        child: SizedBox(
          width: 32,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: WidgetComponents.buildProfileAvatar(
                  url: UserProfileModel.profileAvatarUrl ?? ""),
            ),
          ),
        ),
      ),
    );
  }
}
