import 'package:flutter_test/flutter_test.dart';
import 'package:socmed_auth/main.dart';

void main() {
  testWidgets('StudentApp smoke test loads login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
