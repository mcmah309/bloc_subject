// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class AutoDisposeBlocSubjectProviderRef<E, S>
    extends BlocSubjectProviderRef<E, S> implements AutoDisposeRef<S> {}

// ignore: subtype_of_sealed_class
/// {@macro bloc_subject_provider_auto_dispose}
class AutoDisposeBlocSubjectProvider<E, S>
    extends _BlocSubjectProviderBase<E, S> {
  /// {@macro riverpod.statenotifierprovider}

  AutoDisposeBlocSubjectProvider(
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
  AutoDisposeBlocSubjectProvider.internal(
    this._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro riverpod.family}
  static const family = AutoDisposeStateNotifierProviderFamily.new;

  final BlocSubject<E, S> Function(AutoDisposeBlocSubjectProviderRef<E, S> ref)
      _createFn;

  @override
  BlocSubject<E, S> _create(AutoDisposeBlocSubjectProviderElement<E, S> ref) {
    return _createFn(ref);
  }

  @override
  AutoDisposeBlocSubjectProviderElement<E, S> createElement() {
    return AutoDisposeBlocSubjectProviderElement._(this);
  }

  @override
  late final Refreshable<BlocSubject<E, S>> subject = _notifier(this);

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    Create<BlocSubject<E, S>, AutoDisposeBlocSubjectProviderRef<E, S>> create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AutoDisposeBlocSubjectProvider<E, S>.internal(
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

/// The element of [AutoDisposeBlocSubjectProvider].
class AutoDisposeBlocSubjectProviderElement<E, S>
    extends BlocSubjectProviderElement<E, S>
    with AutoDisposeProviderElementMixin<S>
    implements AutoDisposeBlocSubjectProviderRef<E, S> {
  /// The [ProviderElementBase] for [BlocSubjectProvider]
  AutoDisposeBlocSubjectProviderElement._(
    AutoDisposeBlocSubjectProvider<E, S> super.provider,
  ) : super._();
}
