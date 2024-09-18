sealed class BlocSubjectException implements Exception {
  final String message;

  const BlocSubjectException(this.message);

  @override
  String toString() {
    return message;
  }
}

class SubjectClosed extends BlocSubjectException {
  const SubjectClosed() : super("Subject is closed");
}

class NoInitialValue extends BlocSubjectException {
  const NoInitialValue() : super("State must have initial value");
}
