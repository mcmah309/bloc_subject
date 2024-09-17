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
