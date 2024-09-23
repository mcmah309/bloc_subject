import 'package:bloc_subject/bloc_subject.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';
import 'package:test/test.dart';

sealed class AlphabetState {}

class A implements AlphabetState {}

class B implements AlphabetState {}

class C implements AlphabetState {}

sealed class AlphabetEvent {}

class X implements AlphabetEvent {}

class Y implements AlphabetEvent {}

class Z implements AlphabetEvent {}

void main() {
  test('`await` is needed to change state with event', () async {
    BlocSubject<AlphabetEvent, AlphabetState> subject =
        BlocSubject.seeded(A(), handler: (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    expect(subject.value, isA<A>());

    subject.addEvent(X());

    expect(subject.value, isA<A>());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(subject.value, isA<B>());
  });

  test('`await` is not needed to change state directly', () async {
    BlocSubject<AlphabetEvent, AlphabetState> subject =
        BlocSubject.seeded(A(), handler: (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    expect(subject.value, isA<A>());

    subject.add(B());

    expect(subject.value, isA<B>());
  });

  // test('Change event handle', () async {
  //   BlocSubject<AlphabetEvent, AlphabetState> subject =
  //       BlocSubject.seeded(A(), handler: (event, state) {
  //     switch (event) {
  //       case X():
  //         return B();
  //       case Y():
  //         return B();
  //       case Z():
  //         return null;
  //     }
  //   });

  //   subject.eventHandler((event, state) {
  //     switch (event) {
  //       case X():
  //         return C();
  //       case Y():
  //         return C();
  //       case Z():
  //         return null;
  //     }
  //   });

  //   expect(subject.value, isA<A>());

  //   subject.addEvent(X());

  //   await Future.delayed(const Duration(milliseconds: 100));

  //   expect(subject.value, isA<C>());
  // });

  test('Initial value is present', () async {
    AlphabetState? eventHandler(AlphabetEvent event, AlphabetState state) {
      switch (event) {
        case X():
          return C();
        case Y():
          return C();
        case Z():
          return null;
      }
    }

    BlocSubject<AlphabetEvent, AlphabetState> subject =
        BlocSubject.seeded(A(), handler: eventHandler);
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());

    subject = BlocSubject.wrapped(BehaviorSubject.seeded(A()),
        handler: eventHandler);
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());

    subject = BlocSubject(handler: eventHandler);
    subject.add(A());
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());
  });

  // test('Initial value is not present', () async {
  //   AlphabetState? eventHandler(event, state) {
  //     switch (event) {
  //       case X():
  //         return C();
  //       case Y():
  //         return C();
  //       case Z():
  //         return null;
  //     }
  //   }

  //   BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromStream(Stream.empty());
  //   subject.eventHandler(eventHandler);
  //   expect(subject.hasValue, isFalse);
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(subject.value, isA<A>());
  //   subject.addEvent(X());
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(subject.value, isA<C>());

  //   subject = BlocSubject.fromBehavior(BehaviorSubject.seeded(A()));
  //   subject.eventHandler(eventHandler);
  //   expect(subject.value, isA<A>());
  //   subject.addEvent(X());
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(subject.value, isA<C>());

  //   subject = BlocSubject();
  //   subject.add(A());
  //   subject.eventHandler(eventHandler);
  //   expect(subject.value, isA<A>());
  //   subject.addEvent(X());
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(subject.value, isA<C>());
  // });

  test('debounce and throttle events', () async {
    AlphabetState? eventHandler(AlphabetEvent event, AlphabetState state) {
      switch (event) {
        case X():
          return A();
        case Y():
          return B();
        case Z():
          return C();
      }
    }

    BlocSubject<AlphabetEvent, AlphabetState> subject =
        BlocSubject.seeded(B(), handler: eventHandler);
    expect(subject.value, isA<B>());
    subject.addEvent(X());
    subject.addEvent(Y());
    subject.addEvent(Y());
    subject.addEvent(Y());
    subject.addEvent(Y());
    subject.addEvent(Z());
    Future.delayed(Duration(milliseconds: 1000), subject.close);
    int last = await subject.stream.scan((acc, val, index) => acc + 1, 0).last;
    expect(last, 7);
    expect(subject.value, isA<C>());

    subject = BlocSubject.seeded(B(),
        handler: eventHandler,
        eventsModifier: (events) => events
            .throttle((_) => TimerStream(null, Duration(milliseconds: 300))));
    expect(subject.value, isA<B>());
    subject.addEvent(X());
    await Future.delayed(Duration(milliseconds: 200));
    subject.addEvent(Y());
    subject.addEvent(Y());
    subject.addEvent(Y());
    await Future.delayed(Duration(milliseconds: 200));
    subject.addEvent(Y());
    subject.addEvent(Z());
    Future.delayed(Duration(milliseconds: 1000), subject.close);
    last = await subject.stream.scan((acc, val, index) => acc + 1, 0).last;
    expect(last, 2,
        reason:
            "300 milli between requests. All requests done in 400 milli. Only Called once, plus the original");
    expect(subject.value, isA<B>(),
        reason: "Last call in the 'no call' throttle time");

    subject = BlocSubject.seeded(B(),
        handler: eventHandler,
        eventsModifier: (events) => events
            .debounce((_) => TimerStream(null, Duration(milliseconds: 300))));
    expect(subject.value, isA<B>());
    subject.addEvent(X());
    await Future.delayed(Duration(milliseconds: 200));
    subject.addEvent(Y());
    subject.addEvent(Y());
    subject.addEvent(Y());
    await Future.delayed(Duration(milliseconds: 200));
    subject.addEvent(Y());
    subject.addEvent(Z());
    Future.delayed(Duration(milliseconds: 1000), subject.close);
    last = await subject.stream.scan((acc, val, index) => acc + 1, 0).last;
    expect(last, 2,
        reason:
            "Every next request is within 300 milli of the last, so only the last one gets called.");
    expect(subject.value, isA<C>());
  });
}
