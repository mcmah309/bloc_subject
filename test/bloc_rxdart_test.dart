import 'package:bloc_rxdart/bloc_rxdart.dart';
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
    BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A(), (event, state) {
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
    BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A(), (event, state) {
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
    BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A(), (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    subject.handleEvents((event, state) {
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
}
