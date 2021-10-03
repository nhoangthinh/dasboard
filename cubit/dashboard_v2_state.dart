part of 'dashboard_v2_cubit.dart';

enum ViewMode { EXPANDED, COLLAPSED }

enum QueryProgress { unknown, inProgress, done, failure }

class DashboardV2State extends Equatable {
  DashboardV2State({
    this.viewMode = ViewMode.COLLAPSED,
    this.query,
    this.queryProgress = QueryProgress.unknown,
    this.typeDashboard = 0,
  });

  final ViewMode viewMode;

  final DateTime query;

  final QueryProgress queryProgress;

  final int typeDashboard;

  @override
  List<Object> get props => [viewMode, query, queryProgress, typeDashboard];

  DashboardV2State copyWith({
    ViewMode viewMode,
    DateTime query,
    QueryProgress queryProgress,
    int typeDashboard,
  }) {
    return DashboardV2State(
      viewMode: viewMode ?? this.viewMode,
      query: query ?? this.query,
      queryProgress: queryProgress ?? this.queryProgress,
      typeDashboard: typeDashboard ?? this.typeDashboard,
    );
  }

  bool get isRefreshdable => typeDashboard == 0;

  Color get colorMyDashboard => typeDashboard == 0 ? Colors.blue : Colors.grey;

  Color get colorEmcDashboard => typeDashboard == 1 ? Colors.blue : Colors.grey;

  Color get colorCcDashboard => typeDashboard == 2 ? Colors.blue : Colors.grey;
}
