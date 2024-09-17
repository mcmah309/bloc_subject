import 'package:bloc_rxdart/bloc_rxdart.dart';
import 'package:rxdart/subjects.dart';

extension BlocRxDartOnBehaviorSubject<State> on BehaviorSubject<State> {
  BlocSubject<Event, State> toBloc<Event>([EventHandler<Event, State>? eventHandler]) {
    return BlocSubject.fromBehavior(this);
  }
}
