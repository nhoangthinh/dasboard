import 'package:ehealth/blood_pressure/blood_pressure.dart';
import 'package:ehealth/dashboard_v2/dashboard_v2.dart';
import 'package:ehealth/heart_rate/heart_rate.dart';
import 'package:ehealth/spo2/spo2.dart';
import 'package:flutter/material.dart';

class HealthSliderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5,right: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: Offset(0, 4),
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                ),
              ],
            ),
            child: DashboardDatePicker(),
          ),
          _StackCircle(),
          /*CarouselSlider.builder(
            itemCount: _data.length,
            options: CarouselOptions(
              autoPlay: false,
              autoPlayInterval: Duration(seconds: 1),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              initialPage: _index,
              reverse: false,
              height: MediaQuery.of(context).size.width,
              viewportFraction: 1,
              onPageChanged: (index, _) {
                setState(() {
                  this._index = index;
                });
              },
            ),
            itemBuilder: (context, index) => Container(child: _data[index]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map(
              _data,
              (index, url) {
                return Container(
                  width: this._index == index ? 25 : 8,
                  height: 7,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    color: this._index == index
                        ? const Color(0xFF15A4DD)
                        : const Color(0xFFDDDDDD),
                  ),
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
}

class _StackCircle extends StatefulWidget {
  @override
  _StackCircleState createState() => _StackCircleState();
}

class _StackCircleState extends State<_StackCircle> {
  int _index = 0;
  List<Widget> _data = [];

  @override
  void initState() {
    _data.add(HrCircleChartWidget());
    _data.add(BpCircleChartWidget());
    _data.add(Spo2CircleChart());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _index++;
        if (_index == 3) _index = 0;
        setState(() {});
      },
      child: Container(child: _data[_index]),
    );
  }
}
