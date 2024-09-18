// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class AutoDisposeBlocProviderRef<E, S>
    extends BlocProviderRef<E, S> implements AutoDisposeRef<S> {}

// ignore: subtype_of_sealed_class
/// {@macro bloc_provider_auto_dispose}
class AutoDisposeBlocProvider<E, S>
    extends _BlocProviderBase<E, S> {
  /// {@macro riverpod.statenotifierprovider}

  AutoDisposeBlocProvider(
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
  AutoDisposeBlocProvider.internal(
    this._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro bloc_provider_scoped}
  AutoDisposeBlocProvider.scoped(String name)
      : this(
          (ref) =>
              throw UnimplementedProviderError<AutoDisposeBlocProvider<E, S>>(
            name,
          ),
          name: name,
        );

  /// {@macro riverpod.family}
  static const family = AutoDisposeStateNotifierProviderFamily.new;

  final BlocSubject<E,S> Function(AutoDisposeBlocProviderRef<E, S> ref) _createFn;

  @override
  BlocSubject<E,S> _create(AutoDisposeBlocProviderElement<E, S> ref) {
    return _createFn(ref);
  }

  @override
  AutoDisposeBlocProviderElement<E, S> createElement() {
    return AutoDisposeBlocProviderElement._(this);
  }

  @override
  late final Refreshable<BlocSubject<E,S>> bloc = _notifier(this);

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    Create<BlocSubject<E,S>, AutoDisposeBlocProviderRef<E, S>> create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AutoDisposeBlocProvider<E, S>.internal(
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

/// The element of [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderElement<E, S>
    extends BlocProviderElement<E, S>
    with AutoDisposeProviderElementMixin<S>
    implements AutoDisposeBlocProviderRef<E, S> {
  /// The [ProviderElementBase] for [BlocProvider]
  AutoDisposeBlocProviderElement._(
    AutoDisposeBlocProvider<E, S> super.provider,
  ) : super._();
}
