part of 'home_bloc.dart';

@MappableEnum()
enum HomeStatus { loading, success, failure }

@MappableClass()
class HomeState with HomeStateMappable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.orders = const [],
  });

  final HomeStatus status;

  /// Active orders only (pending, submitted, inProgress, ready). Completed and
  /// cancelled are filtered out by [HomeBloc].
  final List<Order> orders;
}
