import 'package:flutter/material.dart';

class WatchAnimatedWidget extends StatefulWidget {
  WatchAnimatedWidget({
    this.duration = 5,
    this.curve = Curves.linear,
  });

  final int duration;
  final Curve curve;

  @override
  _WatchAnimatedWidgetState createState() => _WatchAnimatedWidgetState();
}

class _WatchAnimatedWidgetState extends State<WatchAnimatedWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        duration: Duration(seconds: widget.duration), vsync: this);
    _animation = Tween<double>(begin: 0, end: 20)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CustomAnimatedWidget(
      controller: _controller,
      animation: _animation,
    );
  }
}

class _CustomAnimatedWidget extends AnimatedWidget {
  _CustomAnimatedWidget({
    AnimationController controller,
    this.animation,
  }) : super(listenable: controller);

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 24.0),
      child: SizedBox(
        width: 32,
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.asset(
            animation.value.toInt() % 2 == 0
                ? "assets/icon/ic_action_bar_device_connect.png"
                : "assets/icon/ic_action_bar_gray_device.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
