/// Riverbloc exposes providers for [Bloc] and [Cubit] instances bases in
/// `riverpod` package instead of `provider` package.
///
/// Providers:
/// - [BlocSubjectProvider]
/// - [AutoDisposeBlocSubjectProvider]
/// - [BlocSubjectProviderFamily]
/// - [AutoDisposeBlocSubjectProviderFamily]
library bloc_subject_provider;

export 'package:bloc_subject/bloc_subject.dart';
export 'package:riverpod/riverpod.dart';

export 'src/framework.dart';
export 'src/when_extensions.dart';
export 'src/unimplemented_provider_error.dart';
