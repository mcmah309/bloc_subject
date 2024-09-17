import 'package:bloc_rxdart/bloc_rxdart.dart';
import 'package:rxdart/subjects.dart';
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
        BlocSubject.fromValue(A(), eventHandler: (event, state) {
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
        BlocSubject.fromValue(A(), eventHandler: (event, state) {
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

  test('Change event handle', () async {
    BlocSubject<AlphabetEvent, AlphabetState> subject =
        BlocSubject.fromValue(A(), eventHandler: (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    subject.eventHandler((event, state) {
      switch (event) {
        case X():
          return C();
        case Y():
          return C();
        case Z():
          return null;
      }
    });

    expect(subject.value, isA<A>());

    subject.addEvent(X());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(subject.value, isA<C>());
  });

  test('Initial value is present', () async {
    AlphabetState? eventHandler(event, state) {
      switch (event) {
        case X():
          return C();
        case Y():
          return C();
        case Z():
          return null;
      }
    }

    BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A());
    subject.eventHandler(eventHandler);
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());

    subject = BlocSubject.fromStream(Stream.value(A()));
    subject.eventHandler(eventHandler);
    expect(subject.hasValue, isFalse);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());

    subject = BlocSubject.fromBehavior(BehaviorSubject.seeded(A()));
    subject.eventHandler(eventHandler);
    expect(subject.value, isA<A>());
    subject.addEvent(X());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<C>());

    subject = BlocSubject();
    subject.add(A());
    subject.eventHandler(eventHandler);
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
}
