import 'package:bloc_subject/bloc_subject.dart';

sealed class AlphabetState {}

class A implements AlphabetState {}

class B implements AlphabetState {}

class C implements AlphabetState {}

sealed class AlphabetEvent {}

class X implements AlphabetEvent {}

class Y implements AlphabetEvent {}

class Z implements AlphabetEvent {}

void main() async {
  BlocSubject<AlphabetEvent, AlphabetState> subject = BlocSubject.fromValue(A(),
      handler: (event, state) => switch (event) {
            X() => A(),
            Y() => B(),
            Z() => null,
          });
  final transformedStream = subject.stream
      .map((value) => switch (value) {
            A() => "A",
            B() => "B",
            C() => "C",
          })
      .distinct();

  assert(subject.value is A);
  assert(await transformedStream.first == "A");

  subject.addEvent(Y()); // Can process events and emit new states
  await Future.delayed(const Duration(milliseconds: 100));
  assert(subject.value is B);
  assert(await transformedStream.first == "B");

  subject.addEvent(Z()); // If null is emitted from the handler, nothing is emitted
  await Future.delayed(const Duration(milliseconds: 100));
  assert(subject.value is B);
  assert(await transformedStream.first == "B");

  subject.add(C()); // Still works like a regular `BehaviorSubject`
  assert(subject.value is C);
  assert(await transformedStream.first == "C");
}
