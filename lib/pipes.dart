library pipes;

import 'dart:async';

import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:rxdart/subjects.dart';

class Pipe<T> implements BehaviorSubject<T> {
  late final BehaviorSubject<T> _behavior;
  final Map<Pipe<T>, StreamSubscription<T>> _subscriptions = {};

  Pipe._(Stream<T> stream, T? initial) {
    if (stream is Subject) {
      // todo
    } else {
      //todo
    }
    if (initial == null) {
      _behavior = BehaviorSubject();
    } else {
      _behavior = BehaviorSubject.seeded(initial);
    }
  }

  factory Pipe.fromStream(Stream<T> stream, {T? initial}) => Pipe._();

  //************************************************************************//

  void attach(Pipe<T> pipe) {
    if (_subscriptions.containsKey(pipe)) {
      return;
    }
    final sub = pipe._behavior.listen((data) {
      // For edge case, allows not having to await `sub.cancel`
      if (_subscriptions[pipe] == null) {
        return;
      }
      _behavior.add(data);
    }, onError: (Object error, StackTrace stackTrace) {
      // For edge case, allows not having to await `sub.cancel`
      if (_subscriptions[pipe] == null) {
        return;
      }
      _behavior.addError(error, stackTrace);
    });
    _subscriptions[pipe] = sub;
  }

  void detach(Pipe<T> pipe) {
    final sub = _subscriptions[pipe];
    if (sub == null) {
      return;
    }
    sub.cancel();
    _subscriptions.remove(pipe);
  }

  /// Remits the last value
  void reEmit() {
    final val = _behavior.valueOrNull;
    if (val == null) {
      return;
    }
    _behavior.add(val);
  }

  // BehaviorSubject
  //************************************************************************//

  @override
  ControllerCancelCallback? get onCancel => _behavior.onCancel;

  @override
  ControllerCallback? get onListen => _behavior.onListen;

  @override
  ControllerCallback get onPause => _behavior.onPause;

  @override
  ControllerCallback get onResume => _behavior.onResume;

  @override
  T get value => _behavior.value;

  @override
  void add(T event) {
    _behavior.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _behavior.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    return _behavior.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future<bool> any(bool Function(T element) test) {
    return _behavior.any(test);
  }

  @override
  Stream<T> asBroadcastStream(
      {void Function(StreamSubscription<T> subscription)? onListen,
      void Function(StreamSubscription<T> subscription)? onCancel}) {
    return _behavior.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(T event) convert) {
    return _behavior.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) {
    return _behavior.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _behavior.cast();
  }

  @override
  Future close() {
    return _behavior.close();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _behavior.contains(needle);
  }

  @override
  Stream<T> distinct([bool Function(T previous, T next)? equals]) {
    return _behavior.distinct(equals);
  }

  @override
  Future get done => _behavior.done;

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _behavior.drain(futureValue);
  }

  @override
  Future<T> elementAt(int index) {
    return _behavior.elementAt(index);
  }

  @override
  Object get error => _behavior.error;

  @override
  Object? get errorOrNull => _behavior.errorOrNull;

  @override
  Future<bool> every(bool Function(T element) test) {
    return _behavior.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(T element) convert) {
    return _behavior.expand(convert);
  }

  @override
  Future<T> get first => _behavior.first;

  @override
  Future<T> firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _behavior.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, T element) combine) {
    return _behavior.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(T element) action) {
    return _behavior.forEach(action);
  }

  @override
  Stream<T> handleError(Function onError, {bool Function(dynamic error)? test}) {
    return _behavior.handleError(onError, test: test);
  }

  @override
  bool get hasError => _behavior.hasError;

  @override
  bool get hasListener => _behavior.hasListener;

  @override
  bool get hasValue => _behavior.hasValue;

  @override
  bool get isBroadcast => _behavior.isBroadcast;

  @override
  bool get isClosed => _behavior.isClosed;

  @override
  Future<bool> get isEmpty => _behavior.isEmpty;

  @override
  bool get isPaused => _behavior.isPaused;

  @override
  Future<String> join([String separator = ""]) {
    return _behavior.join(separator);
  }

  @override
  Future<T> get last => _behavior.last;

  @override
  StreamNotification<T>? get lastEventOrNull => _behavior.lastEventOrNull;

  @override
  Future<T> lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _behavior.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _behavior.length;

  @override
  StreamSubscription<T> listen(void Function(T value)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _behavior.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(T event) convert) {
    return _behavior.map(convert);
  }

  @override
  void onAdd(T event) {
    _behavior.onAdd(event);
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) {
    _behavior.onAddError(error, stackTrace);
  }

  @override
  Future pipe(StreamConsumer<T> streamConsumer) {
    return _behavior.pipe(streamConsumer);
  }

  @override
  Future<T> reduce(T Function(T previous, T element) combine) {
    return _behavior.reduce(combine);
  }

  @override
  Future<T> get single => _behavior.single;

  @override
  Future<T> singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _behavior.singleWhere(test, orElse: orElse);
  }

  @override
  StreamSink<T> get sink => _behavior.sink;

  @override
  Stream<T> skip(int count) {
    return _behavior.skip(count);
  }

  @override
  Stream<T> skipWhile(bool Function(T element) test) {
    return _behavior.skipWhile(test);
  }

  @override
  StackTrace? get stackTrace => _behavior.stackTrace;

  @override
  ValueStream<T> get stream => _behavior.stream;

  @override
  Stream<T> take(int count) {
    return _behavior.take(count);
  }

  @override
  Stream<T> takeWhile(bool Function(T element) test) {
    return _behavior.takeWhile(test);
  }

  @override
  Stream<T> timeout(Duration timeLimit, {void Function(EventSink<T> sink)? onTimeout}) {
    return _behavior.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<T>> toList() {
    return _behavior.toList();
  }

  @override
  Future<Set<T>> toSet() {
    return _behavior.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) {
    return _behavior.transform(streamTransformer);
  }

  @override
  T? get valueOrNull => _behavior.valueOrNull;

  @override
  Stream<T> where(bool Function(T event) test) {
    return _behavior.where(test);
  }
}
