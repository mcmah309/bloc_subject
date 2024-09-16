import 'package:flutter_test/flutter_test.dart';

import 'package:pipes/pipes.dart';

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
    Joint<AlphabetEvent, AlphabetState> joint = Joint.fromValue(A(), (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    expect(joint.value, isA<A>());

    joint.addEvent(X());

    expect(joint.value, isA<A>());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(joint.value, isA<B>());
  });

  test('`await` is not needed to change state directly', () async {
    Joint<AlphabetEvent, AlphabetState> joint = Joint.fromValue(A(), (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    expect(joint.value, isA<A>());

    joint.add(B());

    expect(joint.value, isA<B>());
  });

  test('Change event handle', () async {
    Joint<AlphabetEvent, AlphabetState> joint = Joint.fromValue(A(), (event, state) {
      switch (event) {
        case X():
          return B();
        case Y():
          return B();
        case Z():
          return null;
      }
    });

    joint.handleEvents((event, state) {
      switch (event) {
        case X():
          return C();
        case Y():
          return C();
        case Z():
          return null;
      }
    });

    expect(joint.value, isA<A>());

    joint.addEvent(X());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(joint.value, isA<C>());
  });
}
