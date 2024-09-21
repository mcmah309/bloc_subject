# bloc_subject_provider

Reactive event based state management. Implementation of the Bloc pattern as an rxdart subject (`BlocSubject`) and a riverpod provider for the new subject (`BlocSubjectProvider`).

## Example
```dart
import 'package:bloc_subject_provider/bloc_subject_provider.dart';

final homeBlocProvider = BlocSubjectProvider<HomeEvent, HomeState>((ref) => BlocSubject.fromValue(
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
      })));
```
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_bloc_provider.dart';

class FileSystemAppBar extends ConsumerWidget {

  const FileSystemAppBar({super.key, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentDir = ref.watch(homeBlocProvider).currentDirectory.parent;
    return AppBar(
      leading: parentDir == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                ref
                    .read(homeBlocProvider.subject)
                    .addEvent(HomeEventChangeCurrentDirectory(parentDir.fullPath));
              }),
        ...
    );
  }
}
```