// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template bloc_subject_provider}
/// # BlocSubjectProvider
///
/// Similar to [StateNotifierProvider] but for [BlocSubject]
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
