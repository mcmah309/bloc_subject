// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template riverbloc.auto_dispose_bloc_provider.family}
/// A class that allows building a [AutoDisposeBlocProvider] from an
/// external parameter.
/// {@endtemplate}
///
/// {@template riverbloc.auto_dispose_bloc_provider_family_scoped}
/// # AutoDisposeBlocProviderFamily.scoped
/// Creates an [AutoDisposeBlocProvider] that will be scoped and must be
/// overridden.
/// Otherwise, it will throw an [UnimplementedProviderError].
/// {@endtemplate}
@sealed
class AutoDisposeBlocProviderFamily<E, S, Arg>
    extends AutoDisposeFamilyBase<AutoDisposeBlocProviderRef<E, S>, S, Arg, BlocSubject<E,S>,
        AutoDisposeBlocProvider<E, S>> {
  /// The [Family] of [AutoDisposeBlocProvider].
  AutoDisposeBlocProviderFamily(
    super.create, {
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: AutoDisposeBlocProvider.internal,
          debugGetCreateSourceHash: null,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
        );

  /// {@macro riverbloc.auto_dispose_bloc_provider_family_scoped}
  AutoDisposeBlocProviderFamily.scoped(String name)
      : this(
          (ref, arg) {
            throw UnimplementedProviderError<AutoDisposeBlocProvider<E, S>>(
              name,
            );
          },
          name: name,
        );

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    BlocSubject<E,S> Function(AutoDisposeBlocProviderRef<E, S> ref, Arg arg) create,
  ) {
    return FamilyOverrideImpl<S, Arg, AutoDisposeBlocProvider<E, S>>(
      this,
      (arg) => AutoDisposeBlocProvider<E, S>.internal(
        (ref) => create(ref, arg),
        from: from,
        argument: arg,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        name: null,
      ),
    );
  }
}
