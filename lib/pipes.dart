library pipes;

import 'dart:async';

import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';

typedef JointFn<Event, State> = State? Function(Event, State);

class Joint<Event, State> implements BehaviorSubject<State> {
  final BehaviorSubject<State> _states; // in/out
  final BehaviorSubject<Event> _events = BehaviorSubject(); // in, all events get added here
  Set<StreamSubscription<Event>> additionalEventListeners = {};
  StreamSubscription<State>? _transformSub;

  Joint._(this._states, JointFn<Event, State>? jointFn) {
    if (!_states.hasValue) {
      // todo check if need to yield?
      throw Exception("State must have initial value");
    }
    if (jointFn != null) {
      handleEvents(jointFn);
    }
  }

  factory Joint.fromStream(Stream<State> stream, [JointFn<Event, State>? jointFn]) {
    final BehaviorSubject<State> behavior = BehaviorSubject();
    behavior.addStream(stream);
    return Joint._(behavior, jointFn);
  }

  factory Joint.fromBehavior(BehaviorSubject<State> behavior, [JointFn<Event, State>? jointFn]) {
    return Joint._(behavior, jointFn);
  }

  factory Joint.fromValue(State val, [JointFn<Event, State>? jointFn]) {
    final BehaviorSubject<State> behavior = BehaviorSubject.seeded(val);
    return Joint._(behavior, jointFn);
  }

  //************************************************************************//

  /// Remits the last emitted value
  void reEmit() {
    final val = _states.valueOrNull;
    if (val == null) {
      return;
    }
    _states.add(val);
  }

  void handleEvents(JointFn<Event, State> jointFn) {
    if (_transformSub != null) {
      _transformSub!.cancel();
    }
    final transform = _events.expand<State>((event) {
      final newData = jointFn(event, _states.value);
      if (newData == null) {
        return [];
      }
      return [newData];
    });
    _transformSub = transform.listen((data) {
      _states.add(data);
    }, onError: (Object error, StackTrace stackTrace) {
      _states.addError(error, stackTrace);
    }, onDone: () {
      _states.close();
    });
  }

  void listenToEvents(Stream<Event> events) {
    final sub = events.listen((event) {
      addEvent(event);
    });
    additionalEventListeners.add(sub);
  }

  void addEvent(Event event) {
    _events.add(event);
  }

  // BehaviorSubject
  //************************************************************************//

  @override
  ControllerCancelCallback? get onCancel => _states.onCancel;

  @override
  ControllerCallback? get onListen => _states.onListen;

  @override
  ControllerCallback get onPause => _states.onPause;

  @override
  ControllerCallback get onResume => _states.onResume;

  @override
  State get value => _states.value;

  @override
  set onCancel(ControllerCancelCallback? onCancelHandler) {
    _states.onCancel = onCancelHandler;
  }

  @override
  set onListen(void Function()? onListenHandler) {
    _states.onListen = onListenHandler;
  }

  @override
  set onPause(void Function()? onPauseHandler) {
    _states.onPause = onPauseHandler;
  }

  @override
  set onResume(void Function()? onResumeHandler) {
    _states.onResume = onResumeHandler;
  }

  @override
  set value(State newValue) {
    _states.value = newValue;
  }

  @override
  void add(State event) {
    _states.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _states.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<State> source, {bool? cancelOnError}) {
    return _states.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future<bool> any(bool Function(State element) test) {
    return _states.any(test);
  }

  @override
  Stream<State> asBroadcastStream(
      {void Function(StreamSubscription<State> subscription)? onListen,
      void Function(StreamSubscription<State> subscription)? onCancel}) {
    return _states.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(State event) convert) {
    return _states.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(State event) convert) {
    return _states.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _states.cast();
  }

  @override
  Future close() {
    return _states.close();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _states.contains(needle);
  }

  @override
  Stream<State> distinct([bool Function(State previous, State next)? equals]) {
    return _states.distinct(equals);
  }

  @override
  Future get done => _states.done;

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _states.drain(futureValue);
  }

  @override
  Future<State> elementAt(int index) {
    return _states.elementAt(index);
  }

  @override
  Object get error => _states.error;

  @override
  Object? get errorOrNull => _states.errorOrNull;

  @override
  Future<bool> every(bool Function(State element) test) {
    return _states.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(State element) convert) {
    return _states.expand(convert);
  }

  @override
  Future<State> get first => _states.first;

  @override
  Future<State> firstWhere(bool Function(State element) test, {State Function()? orElse}) {
    return _states.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, State element) combine) {
    return _states.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(State element) action) {
    return _states.forEach(action);
  }

  @override
  Stream<State> handleError(Function onError, {bool Function(dynamic error)? test}) {
    return _states.handleError(onError, test: test);
  }

  @override
  bool get hasError => _states.hasError;

  @override
  bool get hasListener => _states.hasListener;

  @override
  bool get hasValue => _states.hasValue;

  @override
  bool get isBroadcast => _states.isBroadcast;

  @override
  bool get isClosed => _states.isClosed;

  @override
  Future<bool> get isEmpty => _states.isEmpty;

  @override
  bool get isPaused => _states.isPaused;

  @override
  Future<String> join([String separator = ""]) {
    return _states.join(separator);
  }

  @override
  Future<State> get last => _states.last;

  @override
  StreamNotification<State>? get lastEventOrNull => _states.lastEventOrNull;

  @override
  Future<State> lastWhere(bool Function(State element) test, {State Function()? orElse}) {
    return _states.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _states.length;

  @override
  StreamSubscription<State> listen(void Function(State value)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _states.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(State event) convert) {
    return _states.map(convert);
  }

  @override
  void onAdd(State event) {
    _states.onAdd(event);
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) {
    _states.onAddError(error, stackTrace);
  }

  @override
  Future pipe(StreamConsumer<State> streamConsumer) {
    return _states.pipe(streamConsumer);
  }

  @override
  Future<State> reduce(State Function(State previous, State element) combine) {
    return _states.reduce(combine);
  }

  @override
  Future<State> get single => _states.single;

  @override
  Future<State> singleWhere(bool Function(State element) test, {State Function()? orElse}) {
    return _states.singleWhere(test, orElse: orElse);
  }

  @override
  StreamSink<State> get sink => _states.sink;

  @override
  Stream<State> skip(int count) {
    return _states.skip(count);
  }

  @override
  Stream<State> skipWhile(bool Function(State element) test) {
    return _states.skipWhile(test);
  }

  @override
  StackTrace? get stackTrace => _states.stackTrace;

  @override
  ValueStream<State> get stream => _states.stream;

  @override
  Stream<State> take(int count) {
    return _states.take(count);
  }

  @override
  Stream<State> takeWhile(bool Function(State element) test) {
    return _states.takeWhile(test);
  }

  @override
  Stream<State> timeout(Duration timeLimit, {void Function(EventSink<State> sink)? onTimeout}) {
    return _states.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<State>> toList() {
    return _states.toList();
  }

  @override
  Future<Set<State>> toSet() {
    return _states.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<State, S> streamTransformer) {
    return _states.transform(streamTransformer);
  }

  @override
  State? get valueOrNull => _states.valueOrNull;

  @override
  Stream<State> where(bool Function(State event) test) {
    return _states.where(test);
  }
}
