Idea

local
```dart
void main() {
    final stream = createStream();
    final pipe = Pipe.fromStream(stream);
    var _ = pipe.input(otherPipe1); // Can easily combine
    _ = pipe.input(otherPipe2);

    pipe.push(1); // without attaching another Pipe
    pipe.reEmit(); // force re-emitting the last value
    pipe.intercept((data) {

    }, condition: data is X);
    pipe.intercept((data) {
        switch(data) {
            X
        }
    });
}
```

global
```dart
final pipe = Pipe.fromStream(createStream())
    ..input(otherPipe1)
    ..input(otherPipe2);
```
