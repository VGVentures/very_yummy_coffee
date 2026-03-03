part of 'home_bloc.dart';

@MappableClass()
sealed class HomeEvent with HomeEventMappable {
  const HomeEvent();
}

@MappableClass()
class HomeSubscriptionRequested extends HomeEvent
    with HomeSubscriptionRequestedMappable {
  const HomeSubscriptionRequested();
}
