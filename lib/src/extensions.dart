import 'package:bloc_subject/bloc_subject.dart';
import 'package:rxdart/subjects.dart';

extension BlocRxDartOnBehaviorSubject<State> on BehaviorSubject<State> {
  BlocSubject<Event, State> toBloc<Event>(Handler<Event, State> handler,
      {EmptyHandler<Event, State>? emptyHandler}) {
    return BlocSubject.fromBehavior(this, handler: handler, emptyHandler: emptyHandler);
  }
}
