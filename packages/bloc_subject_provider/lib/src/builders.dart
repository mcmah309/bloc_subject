// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// Builds a [BlocProviderFamily].
class BlocProviderFamilyBuilder {
  /// Builds a [BlocProviderFamily].
  const BlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  BlocProviderFamily<E, S, Arg> call<E, S, Arg>(
    FamilyCreate<BlocSubject<E,S>, BlocProviderRef<E, S>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return BlocProviderFamily(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProviderFamilyBuilder get autoDispose {
    return const AutoDisposeBlocProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderBuilder {
  /// Builds a [AutoDisposeBlocProvider].
  const AutoDisposeBlocProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProvider<E, S> call<E, S>(
    Create<BlocSubject<E,S>, AutoDisposeBlocProviderRef<E, S>> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocProvider<E, S>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamilyBuilder get family {
    return const AutoDisposeBlocProviderFamilyBuilder();
  }
}

/// The [Family] of [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderFamilyBuilder {
  /// Builds a [AutoDisposeBlocProviderFamily].
  const AutoDisposeBlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamily<E, S, Arg> call<E, S, Arg>(
    FamilyCreate<BlocSubject<E,S>, AutoDisposeBlocProviderRef<E, S>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocProviderFamily<E, S, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}
