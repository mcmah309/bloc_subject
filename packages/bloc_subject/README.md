[![Pub Version](https://img.shields.io/pub/v/bloc_subject.svg)](https://pub.dev/packages/bloc_subject)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/bloc_subject/latest/)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue)]
[![Build Status](https://github.com/mcmah309/bloc_subject/actions/workflows/dart.yml/badge.svg)](https://github.com/mcmah309/bloc_subject/actions)

# bloc_subject

`bloc_subject` is a Dart package that introduces the `BlocSubject` class, an extension of RxDart's `BehaviorSubject` with the powerful `BLoC` (Business Logic Component) pattern. It allows you to handle events and state changes in a reactive way, leveraging RxDart's stream manipulation capabilities while maintaining state and responding to events asynchronously.

```dart
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

  assert(subject.value is A);
  assert(await transformedStream.first == "A0");

  subject.addEvent(Y()); // Can process events and emit new states
  await Future.delayed(const Duration(milliseconds: 100));
  assert(subject.value is B);
  assert(await transformedStream.first == "B1");

  subject.addEvent(Z()); // If null is emitted from the handler, the state does not change/emit
  await Future.delayed(const Duration(milliseconds: 100));
  assert(subject.value is B);
  assert(await transformedStream.first == "B1");

  subject.add(C(1000)); // Still works like a regular `BehaviorSubject`
  assert(subject.value is C);
  assert(await transformedStream.first == "C1000");
}
```

## Declaration Comparison To Bloc
Bloc:
```dart
import 'package:bloc/bloc.dart';

void main(){
    final bloc = HomeBloc();
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  final DocumentInfoRepository _documentInfoRepository = DI<DocumentInfoRepository>();
  late final StreamSubscription<(DocumentChange<Map<String, dynamic>>, DocumentInfo)>
      _documentInfoChangesStreamSubscription;

  HomeBloc() : super(HomeState()) {
    on<HomeEventAddedDocumentInfo>(_handleAddedDocumentInfo);
    on<HomeEventModifiedDocumentInfo>(_handleModifiedDocumentInfo);
    on<HomeEventRemovedDocumentInfo>(_handleRemovedDocumentInfo);
    on<HomeEventChangeCurrentDirectory>(_handleChangeCurrentDirectory);
    on<HomeEventSortOptionsChanged>(_handleSortOptionsChanged);
    on<HomeEventMoveSelected>(_handleMoveSelectedTo);
    on<HomeEventCreateFolder>(_handleCreateFolderAt);

    _documentInfoChangesStreamSubscription =
        _documentInfoRepository.userDocumentInfoChangeStream().listen((item) {
      final (event, doc) = item;
      switch (event.type) {
        case DocumentChangeType.added:
          add(HomeEventAddedDocumentInfo(doc));
          break;
        case DocumentChangeType.modified:
          add(HomeEventModifiedDocumentInfo(doc));
          break;
        case DocumentChangeType.removed:
          add(HomeEventRemovedDocumentInfo(doc));
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await _documentInfoChangesStreamSubscription.cancel();
    return super.close();
  }

  Future<void> _handleAddedDocumentInfo(HomeEventAddedDocumentInfo event, Emitter<HomeState> emit) async {
    ...
  }

  Future<void> _handleModifiedDocumentInfo(HomeEventModifiedDocumentInfo event, Emitter<HomeState> emit) async {
    ...
  }

  Future<void> _handleRemovedDocumentInfo(HomeEventRemovedDocumentInfo event, Emitter<HomeState> emit) async {
    ...
  }

  void _handleChangeCurrentDirectory(HomeEventChangeCurrentDirectory event, Emitter<HomeState> emit) {
    ...
  }

  void _handleSortOptionsChanged(HomeEventSortOptionsChanged event, Emitter<HomeState> emit) {
    ...
  }

  void _handleMoveSelectedTo(HomeEventMoveSelected event, Emitter<HomeState> emit) {
    ...
  }

  void _handleCreateFolderAt(HomeEventCreateFolder event, Emitter<HomeState> emit) {
    ...
  }
}
```

bloc_subject:
```dart
import 'package:bloc_subject/bloc_subject.dart';

void main() {
    final blocSubject = BlocSubject<HomeEvent, HomeState>.fromValue(
        HomeState(),
        handler: (event, state) => switch (event) {
            HomeEventAddedDocumentInfo() => _handleAddedDocumentInfo(event, state),
            HomeEventModifiedDocumentInfo() => _handleModifiedDocumentInfo(event, state),
            HomeEventRemovedDocumentInfo() => _handleRemovedDocumentInfo(event, state),
            HomeEventChangeCurrentDirectory() => _handleChangeCurrentDirectory(event, state),
            HomeEventSortOptionsChanged() => _handleSortOptionsChanged(event, state),
            HomeEventMoveSelected() => _handleMoveSelectedTo(event, state),
            HomeEventCreateFolder() => _handleCreateFolderAt(event, state),
        },
        )..listenToEvents(DI<DocumentInfoRepository>().userDocumentInfoChangeStream().map((item) {
            final (event, doc) = item;
            return switch (event.type) {
                DocumentChangeType.added => HomeEventAddedDocumentInfo(doc),
                DocumentChangeType.modified => HomeEventModifiedDocumentInfo(doc),
                DocumentChangeType.removed => HomeEventRemovedDocumentInfo(doc),
            };
        }));
}

HomeState? _handleAddedDocumentInfo(HomeEventAddedDocumentInfo event, HomeState state) {
    ...
}

HomeState? _handleModifiedDocumentInfo(HomeEventModifiedDocumentInfo event, HomeState state) {
    ...
}

HomeState? _handleRemovedDocumentInfo(HomeEventRemovedDocumentInfo event, HomeState state) {
    ...
}

HomeState? _handleChangeCurrentDirectory(HomeEventChangeCurrentDirectory event, HomeState state) {
    ...
}

HomeState? _handleSortOptionsChanged(HomeEventSortOptionsChanged event, HomeState state) {
    ...
}

HomeState? _handleMoveSelectedTo(HomeEventMoveSelected event, HomeState state) {
    ...
}

HomeState? _handleCreateFolderAt(HomeEventCreateFolder event, HomeState state) {
    ...
}
```