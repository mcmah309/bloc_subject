// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// Builds a [BlocSubjectProviderFamily].
class BlocSubjectProviderFamilyBuilder {
  /// Builds a [BlocSubjectProviderFamily].
  const BlocSubjectProviderFamilyBuilder();

  /// {@macro riverpod.family}
  BlocSubjectProviderFamily<E, S, Arg> call<E, S, Arg>(
    FamilyCreate<BlocSubject<E, S>, BlocSubjectProviderRef<E, S>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return BlocSubjectProviderFamily(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocSubjectProviderFamilyBuilder get autoDispose {
    return const AutoDisposeBlocSubjectProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeBlocSubjectProvider].
class AutoDisposeBlocSubjectProviderBuilder {
  /// Builds a [AutoDisposeBlocSubjectProvider].
  const AutoDisposeBlocSubjectProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocSubjectProvider<E, S> call<E, S>(
    Create<BlocSubject<E, S>, AutoDisposeBlocSubjectProviderRef<E, S>> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocSubjectProvider<E, S>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeBlocSubjectProviderFamilyBuilder get family {
    return const AutoDisposeBlocSubjectProviderFamilyBuilder();
  }
}

/// The [Family] of [AutoDisposeBlocSubjectProvider].
class AutoDisposeBlocSubjectProviderFamilyBuilder {
  /// Builds a [AutoDisposeBlocSubjectProviderFamily].
  const AutoDisposeBlocSubjectProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeBlocSubjectProviderFamily<E, S, Arg> call<E, S, Arg>(
    FamilyCreate<BlocSubject<E, S>, AutoDisposeBlocSubjectProviderRef<E, S>,
            Arg>
        create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocSubjectProviderFamily<E, S, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}
