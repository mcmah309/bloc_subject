// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template bloc_provider}
/// # BlocSubjectProvider
///
/// Similar to [StateNotifierProvider] but for [BlocBase] ([Bloc] and [Cubit])
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit(int state) : super(state);
///
///   void increment() => emit(state + 1);
/// }
///
/// final counterCubitProvider =
///     BlocSubjectProvider<CounterCubit, int>((ref) => CounterCubit(0));
///
/// class MyHomePage extends ConsumerWidget {
///   const MyHomePage({Key? key, required this.title}) : super(key: key);
///
///   final String title;
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Rebuilds the widget if the cubit/bloc changes.
///     // But does not rebuild if the state changes with the same cubit/bloc
///     final counterCubit = ref.watch(counterCubitProvider.notifier);
///     return Scaffold(
///       appBar: AppBar(
///         title: Text(title),
///       ),
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: <Widget>[
///             Text(
///               'initial counterCubit.state: ${counterCubit.state}',
///             ),
///             Consumer(builder: (context, ref, __) {
///               // Rebuilds on every emitted state
///               final _counter = ref.watch(counterCubitProvider);
///               return Text(
///                 '$_counter',
///                 style: Theme.of(context).textTheme.headline4,
///               );
///             }),
///           ],
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: () {
///           ref.read(counterCubitProvider.notifier).increment();
///         }
///         tooltip: 'Increment',
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_notifier}
/// ## `BlocSubjectProvider.notifier`
/// `BlocBase` object getter, it can be either `Bloc`
/// or `Cubit`.
///
/// Usage:
///
/// ```dart
/// Consumer(builder: (context, ref, __) {
///   return ElevatedButton(
///     style: style,
///     onPressed: () {
///       ref.read(counterBlocSubjectProvider.notifier).increment();
///     },
///     child: const Text('Press me'),
///   );
/// }),
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_bloc}
/// ## `BlocSubjectProvider.bloc`
/// `BlocBase` object getter, it can be either `Bloc`
/// or `Cubit`.
///
/// Usage:
///
/// ```dart
/// Consumer(builder: (context, ref, __) {
///   return ElevatedButton(
///     style: style,
///     onPressed: () {
///       ref.read(counterBlocSubjectProvider.bloc).increment();
///     },
///     child: const Text('Press me'),
///   );
/// }),
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_scoped}
/// Creates a [BlocSubjectProvider] that needs to be overridden
///
/// With pure dart:
///
/// ```dart
/// final blocProvider = BlocSubjectProvider<CounterBloc, int>.scoped('blocProvider');
///
/// final container = ProviderContainer(
///   overrides: [
///     blocProvider
///         .overrideWithProvider(BlocSubjectProvider((ref) => CounterBloc(0))),
///   ],
/// );
///
/// final counter = container.read(blocProvider); // counter = 0
/// ```
///
/// With Flutter:
///
/// ```dart
/// final blocProvider = BlocSubjectProvider<CounterBloc, int>.scoped('blocProvider');
///
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return ProviderScope(
///       overrides: [
///         blocProvider
///             .overrideWithProvider(BlocSubjectProvider((ref) => CounterBloc(0))),
///       ],
///       child: Consumer(
///         builder: (context, ref, child) {
///           final counter = ref.watch(blocProvider);  // counter = 0
///           return Text('$counter');
///         }
///       )
///     );
///   }
/// }
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_override_with_provider}
/// ## `BlocSubjectProvider.overrideWithProvider`
///
/// With pure dart:
///
/// ```dart
/// final counterProvider = BlocSubjectProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final counterProvider2 = BlocSubjectProvider((ref) => counterCubit);
/// final container = ProviderContainer(
///   overrides: [
///     counterProvider.overrideWithProvider(counterProvider2),
///   ],
/// );
///
/// // reads `counterProvider2` and returns `counterCubit`
/// container.read(counterProvider.notifier);
///
/// // reads the `counterProvider2` `state` and returns `3`
/// container.read(counterProvider);
/// ```
///
/// With Flutter:
///
/// ```dart
/// final counterProvider = BlocSubjectProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final counterProvider2 = BlocSubjectProvider((ref) => counterCubit);
///
/// ProviderScope(
///   overrides: [
///     counterProvider.overrideWithProvider(counterProvider2),
///   ],
///   child: Consumer(
///     builder: (context, ref, _) {
///       final countCubit = ref.watch(counterProvider.notifier);
///       return Container();
///     },
///   ),
/// );
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_override_with_value}
/// ## `BlocSubjectProvider.overrideWithValue`
///
/// With pure dart:
///
/// ```dart
/// final counterProvider = BlocSubjectProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final container = ProviderContainer(
///   overrides: [
///     counterProvider.overrideWithValue(counterCubit),
///   ],
/// );
///
/// // reads `counterProvider` and returns `counterCubit`
/// container.read(counterProvider.notifier);
///
/// // reads the `counterProvider.state` and returns `3`
/// container.read(counterProvider);
/// ```
///
/// With Flutter:
///
/// ```dart
/// final counterProvider = BlocSubjectProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
///
/// ProviderScope(
///   overrides: [
///     counterProvider.overrideWithValue(counterCubit),
///   ],
///   child: Consumer(
///     builder: (context, ref, _) {
///       final countCubit = ref.watch(counterProvider.notifier);
///       return Container();
///     },
///   ),
/// );
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_auto_dispose}
/// ## Auto Dispose
/// Marks the provider as automatically disposed when no-longer listened.
///
/// ```dart
/// final counterProvider1 = BlocSubjectProvider.autoDispose((ref) => CounterCubit(0));
///
/// final counterProvider2 - AutoDisposeBlocSubjectProvider((ref) => CounterCubit(0));
/// ```
/// The `maintainState` property is a boolean (`false` by default) that allows
/// the provider to tell Riverpod if the state of the provider should be
/// preserved even if no-longer listened.
///
/// ```dart
/// final myProvider = BlocSubjectProvider.autoDispose((ref) {
///   final asyncValue = ref.watch(myFutureProvider);
///   final firstState = asyncValue.data!.value;
///   ref.maintainState = true;
///   return CounterBloc(firstState);
/// });
/// ```
///
/// This way, if the `asyncValue` has no data, the provider won't create
/// correctly the state and if the UI leaves the screen and re-enters it,
/// the `asyncValue` will be readed again to retry creating the state.
/// {@endtemplate}
///
/// {@template bloc_provider_when}
/// ## `BlocSubjectProvider.when`
///
/// For conditional rebuilds, you can use the `when` property.
///
/// ```dart
/// ref.watch(
///   counterBlocSubjectProvider
///     .when((previous, current) => current > previous)),
/// );
///
/// ref.watch(
///   blocProvider
///     .when((prev, curr) => true)
///     .select((state) => state.field),
///   (field) { /* do something */ }
/// );
/// ```
///
/// or for conditional listening:
///
/// ```dart
/// ref.listen(
///   counterBlocSubjectProvider
///     .when((previous, current) => current > previous)),
/// );
///
/// ref.listen(
///   blocProvider
///     .when((prev, curr) => true)
///     .select((state) => state.field),
///   (field) { /* do something*/ }
/// );
/// ```
/// {@endtemplate}
class BlocSubjectProvider<E, S> extends _BlocSubjectProviderBase<E, S>
    with AlwaysAliveProviderBase<S> {
  /// {@macro riverpod.statenotifierprovider}
  BlocSubjectProvider(
    this._createFn, {
    super.name,
    super.dependencies,
    @Deprecated('Will be removed in 3.0.0') super.from,
    @Deprecated('Will be removed in 3.0.0') super.argument,
    @Deprecated('Will be removed in 3.0.0') super.debugGetCreateSourceHash,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
        );

  /// An implementation detail of Riverpod
  @internal
  BlocSubjectProvider.internal(
    this._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro bloc_provider_scoped}
  BlocSubjectProvider.scoped(String name)
      : this(
          (ref) => throw UnimplementedProviderError<BlocSubjectProvider<E, S>>(name),
          name: name,
        );

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeBlocSubjectProviderBuilder();

  /// {@macro riverpod.family}
  static const family = BlocSubjectProviderFamilyBuilder();

  final BlocSubject<E,S> Function(BlocSubjectProviderRef<E, S> ref) _createFn;

  @override
  BlocSubject<E,S> _create(BlocSubjectProviderElement<E, S> ref) {
    return _createFn(ref);
  }

  @override
  BlocSubjectProviderElement<E, S> createElement() {
    return BlocSubjectProviderElement<E, S>._(this);
  }

  @override
  late final AlwaysAliveRefreshable<BlocSubject<E,S>> bloc = _notifier(this);

  /// {@macro riverpod.overridewith}
  Override overrideWith(Create<BlocSubject<E,S>, BlocSubjectProviderRef<E, S>> create) {
    return ProviderOverride(
      origin: this,
      override: BlocSubjectProvider<E, S>.internal(
        create,
        from: from,
        argument: argument,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        name: null,
      ),
    );
  }
}
