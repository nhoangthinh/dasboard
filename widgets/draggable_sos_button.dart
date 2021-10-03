import 'package:ehealth/core/base/import/base_import_components.dart';
import 'package:ehealth/widget/sos_button.dart';
import 'package:flutter/material.dart';

class DraggableSosButton extends StatefulWidget {
  DraggableSosButton({
    this.isHasAppBar = false,
    this.appBarHeight = 80,
  });

  final bool isHasAppBar;
  final double appBarHeight;

  @override
  _DraggableSosButtonState createState() => _DraggableSosButtonState();
}

class _DraggableSosButtonState extends State<DraggableSosButton> {
  Offset _position;
  double _top = 10;
  double _left = 10;
  sosButton _sosButton;

  @override
  void didChangeDependencies() {
    _left = MediaQuery.of(context).size.width;
    _top = MediaQuery.of(context).size.height;
    if (widget.isHasAppBar) _top -= widget.appBarHeight;
    if (Get.height >= 812 && Platform.isIOS) {
      _position = Offset(_left - 70, _top - 155);
    } else {
      _position = Offset(_left - 70, _top - 135);
    }
    _sosButton = const sosButton();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: Draggable(
        feedback: _sosButton,
        child: _sosButton,
        childWhenDragging: SizedBox(),
        onDragEnd: (details) {
          double _dx = details.offset.dx;
          double _dy = details.offset.dy;
          if (widget.isHasAppBar) _dy = _dy - widget.appBarHeight;
          if (_dx< 0) _dx = 0;
          if (_dy < 0) _dy = 0;
          if (_dx > (_left - 55)) {
            _dx = _left - 55;
          }
          if (Get.height >= 812 && Platform.isIOS) { // Fix UI iOS
            if (_dy > (_top - 155)) {
              _dy = _top - 155;
            }
          } else {
            if (_dy > (_top - 135)) {
              _dy = _top - 135;
            }
          }
          setState(() => _position = Offset(_dx, _dy));
        },
      ),
    );
  }
}
