import 'package:bloc_subject/bloc_subject.dart';
import 'package:bloc_subject_provider/src/framework.dart';
import 'package:flutter_test/flutter_test.dart';

final BlocSubjectProvider<int, String> blocSubjectProvider =
    BlocSubjectProvider((ref) => BlocSubject.wrapped("",
        handler: (event, state) => null));

void main() {
  test('test', () {});
}
