import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'exceptions.dart';

/// Handler for [Event]s.
typedef Handler<Event, State> = FutureOr<State?> Function(
    Event event, State state);

/// {@template empty_handler}
/// Empty [State] handler.
/// In some cases it is possible for an [Event] to be received before the first [State] is set.
/// This is the callback for these cases.
/// To avoid this, when needed, consider using [waitForState] before adding any [Event]s.
/// See [BlocSubject.defaultEmptyHandler] for modifying the default implementation.
/// {@endtemplate}
typedef EmptyHandler<Event, State> = FutureOr<State?> Function(Event event);

/// Used to modify the event stream such a debouncing.
/// Applied to all events - [addEvent] or [listenToEvents].
typedef EventsModifier<Event> = Stream<Event> Function(Stream<Event> events);

/// A [BehaviorSubject] that handles [Event]s and modify the [State] based on the [Event]s.
class BlocSubject<Event, State> implements BehaviorSubject<State> {
  /// For constructors that offer a [EmptyHandler], if no [EmptyHandler] is provided, this will be called.
  /// The default is to throw an exception to make debugging easier.
  static EmptyHandler defaultEmptyHandler = (event) => throw NoInitialValue();

  final BehaviorSubject<State> _states; // in/out
  final BehaviorSubject<Event> _events =
      BehaviorSubject(); // in, all events get added here
  final Set<StreamSubscription<Event>> _additionalEventSubscriptions = {};
  StreamSubscription<State>? _transformSubscription;

  BlocSubject._(
      this._states,
      Handler<Event, State> handler,
      EmptyHandler<Event, State>? emptyHandler,
      EventsModifier<Event>? eventsModifier) {
    _eventHandler(handler,
        emptyHandler: emptyHandler, eventsModifier: eventsModifier);
  }

  factory BlocSubject({
    required Handler<Event, State> handler,

    /// {@macro empty_handler}
    /// Note, this does not matter if [add] is called before any yield.
    EmptyHandler<Event, State>? emptyHandler,
    EventsModifier<Event>? eventsModifier,
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final BehaviorSubject<State> behavior =
        BehaviorSubject(onListen: onListen, onCancel: onCancel, sync: sync);
    return BlocSubject._(behavior, handler, emptyHandler, eventsModifier);
  }

  factory BlocSubject.fromStream(
    Stream<State> stream, {
    required Handler<Event, State> handler,

    /// {@macro empty_handler}
    /// Note, even if this stream already holds a value, you may need to yield for the value to be seen by this Subject.
    EmptyHandler<Event, State>? emptyHandler,
    EventsModifier<Event>? eventsModifier,
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final BehaviorSubject<State> behavior =
        BehaviorSubject(onListen: onListen, onCancel: onCancel, sync: sync);
    behavior.addStream(stream);
    return BlocSubject._(behavior, handler, emptyHandler, eventsModifier);
  }

  factory BlocSubject.fromBehavior(
    BehaviorSubject<State> behavior, {
    required Handler<Event, State> handler,

    /// {@macro empty_handler}
    /// This does not matter if [behavior] already has a value, such as when created from the `seeded` constructor or [add] is called before any yield.
    EmptyHandler<Event, State>? emptyHandler,
    EventsModifier<Event>? eventsModifier,
  }) {
    return BlocSubject._(behavior, handler, emptyHandler, eventsModifier);
  }

  factory BlocSubject.fromValue(
    State val, {
    required Handler<Event, State> handler,
    EventsModifier<Event>? eventsModifier,
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final BehaviorSubject<State> behavior = BehaviorSubject.seeded(val,
        onListen: onListen, onCancel: onCancel, sync: sync);
    return BlocSubject._(behavior, handler, null, eventsModifier);
  }

  //************************************************************************//

  void _eventHandler(Handler<Event, State> handler,
      {EmptyHandler<Event, State>? emptyHandler,
      EventsModifier<Event>? eventsModifier}) {
    if (_transformSubscription != null) {
      _transformSubscription!.cancel();
    }
    final Stream<Event> events;
    if (eventsModifier == null) {
      events = _events;
    } else {
      events = eventsModifier(_events);
    }
    final transform = events.flatMap<State>((event) async* {
      final value = _states.valueOrNull;
      final State? newData;
      if (value == null) {
        if (emptyHandler == null) {
          defaultEmptyHandler(event);
          return;
        } else {
          newData = await emptyHandler(event);
        }
      } else {
        newData = await handler(event, _states.value);
      }
      if (newData == null) {
        return;
      }
      yield newData;
    });
    _transformSubscription = transform.listen((data) {
      _states.add(data);
    }, onError: (Object error, StackTrace stackTrace) {
      _states.addError(error, stackTrace);
    }, onDone: () {
      _states.close();
    });
  }

  //************************************************************************//

  /// Remits the last emitted value
  void reEmit() {
    if (isClosed) {
      throw const SubjectClosed();
    }
    if (!_states.hasValue) {
      throw const NoInitialValue();
    }
    final val = _states.value;
    _states.add(val);
  }

  void listenToEvents(Stream<Event> events) {
    if (isClosed) {
      throw const SubjectClosed();
    }
    final sub = events.listen((event) {
      addEvent(event);
    });
    _additionalEventSubscriptions.add(sub);
  }

  /// Adds an event. Note an event is not immediately processed. You need to yield to the scheduler since
  /// `handleEvents` functions is allowed to be async.
  void addEvent(Event event) {
    if (isClosed) {
      throw const SubjectClosed();
    }
    _events.add(event);
  }

  /// Waits for the state to exist or for the optionally given [timeout]. Returns `true` if the state exists or
  /// `false` if the state does not exist within the timeout.
  Future<bool> waitForState([Duration? timeout]) async {
    if (_states.hasValue) {
      return true;
    }
    if (timeout == null) {
      return _states.first.then((v) => true);
    }
    try {
      await _states.first.timeout(timeout);
      return true;
    } on TimeoutException catch (_) {
      return false;
    }
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
    _transformSubscription?.cancel();
    _events.close();
    for (final sub in _additionalEventSubscriptions) {
      sub.cancel();
    }
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
  Future<State> firstWhere(bool Function(State element) test,
      {State Function()? orElse}) {
    return _states.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, State element) combine) {
    return _states.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(State element) action) {
    return _states.forEach(action);
  }

  @override
  Stream<State> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
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
  Future<State> lastWhere(bool Function(State element) test,
      {State Function()? orElse}) {
    return _states.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _states.length;

  @override
  StreamSubscription<State> listen(void Function(State value)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _states.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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
  Future<State> singleWhere(bool Function(State element) test,
      {State Function()? orElse}) {
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
  Stream<State> timeout(Duration timeLimit,
      {void Function(EventSink<State> sink)? onTimeout}) {
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
