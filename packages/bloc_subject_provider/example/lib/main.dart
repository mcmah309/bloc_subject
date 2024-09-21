import 'package:bloc_subject_provider/bloc_subject_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class Event {}

class Event1 implements Event {
  int number;

  Event1(this.number);
}

class Event2 implements Event {
  int number;

  Event2(this.number);
}

final BlocSubjectProvider<Event, int> blocSubjectProvider = BlocSubjectProvider(
    (ref) => BlocSubject.fromValue(1, handler: (event, state) {
          switch (event) {
            case Event1(:final number):
              // ignore: avoid_print
              print("event 1");
              return state + number;
            case Event2(:final number):
              // ignore: avoid_print
              print("event 2");
              return state + number;
          }
        }));

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(blocSubjectProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(blocSubjectProvider.subject).addEvent(Event1(1)),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
