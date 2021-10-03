import 'package:ehealth/contact/contact.dart';

class ListDashboardWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0,2),
            color: Color.fromRGBO(0, 10, 62, .05),
          ),
        ]
      ),
      child: BlocBuilder<DashboardV2Cubit, DashboardV2State>(
        buildWhen: (pre, cur) => pre.typeDashboard != cur.typeDashboard,
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: Dimensions.PADDING_NORMAL,
              runSpacing: 0.0,
              children: <Widget>[
                const SizedBox(width: 8),
                ButtonBorderWidget(
                  "my_dashboard",
                  () => context.read<DashboardV2Cubit>().onChangeDashboard(0),
                  color: state.colorMyDashboard,
                ),
                ButtonBorderWidget(
                  "emc_dashboard",
                  () => context.read<DashboardV2Cubit>().onChangeDashboard(1),
                  color: state.colorEmcDashboard,
                ),
                ButtonBorderWidget(
                  "caring_dashboard",
                  () => context.read<DashboardV2Cubit>().onChangeDashboard(2),
                  color: state.colorCcDashboard,
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
