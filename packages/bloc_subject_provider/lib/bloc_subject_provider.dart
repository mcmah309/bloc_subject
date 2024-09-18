/// Riverbloc exposes providers for [Bloc] and [Cubit] instances bases in
/// `riverpod` package instead of `provider` package.
///
/// Providers:
/// - [BlocProvider]
/// - [AutoDisposeBlocProvider]
/// - [BlocProviderFamily]
/// - [AutoDisposeBlocProviderFamily]
library bloc_subject_provider;

import 'package:bloc_subject/bloc_subject.dart';
export 'package:riverpod/riverpod.dart';

export 'src/framework.dart';
export 'src/listenable_provider_whenable.dart';
export 'src/unimplemented_provider_error.dart';
