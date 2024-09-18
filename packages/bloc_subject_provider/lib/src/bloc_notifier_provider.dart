// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class BlocSubjectProviderRef<E, S> implements Ref<S> {
  /// The [Bloc] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  BlocSubject<E,S> get bloc;
}

/// The element of [StateNotifierProvider].
class BlocSubjectProviderElement<E, S>
    extends ProviderElementBase<S> implements BlocSubjectProviderRef<E, S> {
  BlocSubjectProviderElement._(_BlocSubjectProviderBase<E, S> super.provider);

  @override
  BlocSubject<E,S> get bloc => _blocNotifier.value;
  final _blocNotifier = ProxyElementValueNotifier<BlocSubject<E,S>>();

  void Function()? _removeListener;

  @override
  void create({required bool didChangeDependency}) {
    final provider = this.provider as _BlocSubjectProviderBase<E, S>;

    final notifier =
        _blocNotifier.result = Result.guard(() => provider._create(this));

    setState(notifier.requireState.value); //todo

    final sub = notifier.requireState.stream.listen(setState);

    _removeListener = sub.cancel;
  }

  @override
  bool updateShouldNotify(S previous, S next) {
    return previous != next;
  }

  @override
  void runOnDispose() {
    super.runOnDispose();

    _removeListener?.call();
    _removeListener = null;

    final notifier = _blocNotifier.result?.stateOrNull;
    if (notifier != null) {
      runGuarded(notifier.close);
    }
    _blocNotifier.result = null;
  }

  @override
  void visitChildren({
    required void Function(ProviderElementBase<dynamic> element) elementVisitor,
    required void Function(ProxyElementValueNotifier<dynamic> element)
        notifierVisitor,
  }) {
    super.visitChildren(
      elementVisitor: elementVisitor,
      notifierVisitor: notifierVisitor,
    );
    notifierVisitor(_blocNotifier);
  }
}

ProviderElementProxy<S, BlocSubject<E,S>> _notifier<E, S>(
  _BlocSubjectProviderBase<E, S> that,
) {
  return ProviderElementProxy<S, BlocSubject<E,S>>(
    that,
    (element) {
      return (element as BlocSubjectProviderElement<E, S>)._blocNotifier;
    },
  );
}

// ignore: subtype_of_sealed_class
abstract class _BlocSubjectProviderBase<E, S>
    extends ProviderBase<S> {
  const _BlocSubjectProviderBase({
    required super.name,
    required super.from,
    required super.argument,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
  });

  /// Obtains the [Bloc] associated with this provider, without listening
  /// to state changes.
  ///
  /// This is typically used to invoke methods on a [Bloc]. For example:
  ///
  /// ```dart
  /// Button(
  ///   onTap: () => ref.read(counterProvider.bloc).add(Increment()),
  /// )
  /// ```
  ///
  /// This listenable will notify its state if the [Bloc] or [Cubit] instance
  /// changes.
  /// This may happen if the provider is refreshed or one of its dependencies
  /// has changes.
  ProviderListenable<BlocSubject<E,S>> get bloc;

  BlocSubject<E,S> _create(covariant BlocSubjectProviderElement<E, S> ref);
}
