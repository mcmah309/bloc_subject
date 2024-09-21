import 'package:bloc_subject/bloc_subject.dart';
import 'package:test/test.dart';

sealed class AlphabetState {
  final int id;

  AlphabetState(this.id);
}

class A extends AlphabetState {
  A(super.id);
}

class B extends AlphabetState {
  B(super.id);
}

class C extends AlphabetState {
  C(super.id);
}

sealed class AlphabetEvent {}

class X implements AlphabetEvent {}

class Y implements AlphabetEvent {}

class Z implements AlphabetEvent {}

void main() async {
  test('example test', () async {
    int emitCount = 0;
    BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A(emitCount),
        handler: (event, state) => switch (event) {
              X() => A(++emitCount),
              Y() => B(++emitCount),
              Z() => null,
            });
    final transformedStream = subject.stream
        .map((value) => switch (value) {
              A() => "A${value.id}",
              B() => "B${value.id}",
              C() => "C${value.id}",
            })
        .distinct();

    expect(subject.value, isA<A>());
    expect(await transformedStream.first, "A0");

    subject.addEvent(Y()); // Can process events and emit new states
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<B>());
    expect(await transformedStream.first, "B1");

    subject.addEvent(Z()); // If null is emitted from the handler, the state does not change/emit
    await Future.delayed(const Duration(milliseconds: 100));
    expect(subject.value, isA<B>());
    expect(await transformedStream.first, "B1");

    subject.add(C(1000)); // Still works like a regular `BehaviorSubject`
    expect(subject.value, isA<C>());
    expect(await transformedStream.first, "C1000");
  });
}
