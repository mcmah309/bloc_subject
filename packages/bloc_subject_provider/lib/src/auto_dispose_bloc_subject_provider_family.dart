// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template riverbloc.auto_dispose_bloc_provider.family}
/// A class that allows building a [AutoDisposeBlocSubjectProvider] from an
/// external parameter.
/// {@endtemplate}
///
/// {@template riverbloc.auto_dispose_bloc_provider_family_scoped}
/// # AutoDisposeBlocSubjectProviderFamily.scoped
/// Creates an [AutoDisposeBlocSubjectProvider] that will be scoped and must be
/// overridden.
/// Otherwise, it will throw an [UnimplementedProviderError].
/// {@endtemplate}
@sealed
class AutoDisposeBlocSubjectProviderFamily<E, S, Arg>
    extends AutoDisposeFamilyBase<AutoDisposeBlocSubjectProviderRef<E, S>, S, Arg, BlocSubject<E,S>,
        AutoDisposeBlocSubjectProvider<E, S>> {
  /// The [Family] of [AutoDisposeBlocSubjectProvider].
  AutoDisposeBlocSubjectProviderFamily(
    super.create, {
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: AutoDisposeBlocSubjectProvider.internal,
          debugGetCreateSourceHash: null,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
        );

  /// {@macro riverbloc.auto_dispose_bloc_provider_family_scoped}
  AutoDisposeBlocSubjectProviderFamily.scoped(String name)
      : this(
          (ref, arg) {
            throw UnimplementedProviderError<AutoDisposeBlocSubjectProvider<E, S>>(
              name,
            );
          },
          name: name,
        );

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    BlocSubject<E,S> Function(AutoDisposeBlocSubjectProviderRef<E, S> ref, Arg arg) create,
  ) {
    return FamilyOverrideImpl<S, Arg, AutoDisposeBlocSubjectProvider<E, S>>(
      this,
      (arg) => AutoDisposeBlocSubjectProvider<E, S>.internal(
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
