import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socmed_auth/demo_auth.dart';
import 'package:socmed_auth/main.dart';
import 'package:socmed_auth/social_media/post.dart';
import 'package:socmed_auth/social_media/post_card.dart';
import 'package:socmed_auth/social_media/create_post_sheet.dart';

void main() {
  setUp(() {
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  group('DemoAuth tests', () {
    test('Default admin credentials work', () {
      expect(DemoAuth.login('admin', 'admin123'), isTrue);
      expect(DemoAuth.currentUsername, 'admin');
    });

    test('Invalid credentials fail', () {
      expect(DemoAuth.login('wrong', 'wrongpass'), isFalse);
      expect(DemoAuth.currentUsername, isNull);
    });

    test('Registration and registered login work', () {
      DemoAuth.register('student1', 'password123');
      expect(DemoAuth.login('student1', 'password123'), isTrue);
      expect(DemoAuth.currentUsername, 'student1');

      DemoAuth.logout();
      expect(DemoAuth.currentUsername, isNull);
    });
  });

  group('PostCard Widget tests', () {
    testWidgets('Likes toggle and comments are added properly',
        (WidgetTester tester) async {
      const post = Post(
        username: 'TestUser',
        caption: 'Hello World Caption',
        imageUrl: 'https://example.com/test.jpg',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(post: post),
            ),
          ),
        ),
      );

      // Verify post content
      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('Hello World Caption'), findsOneWidget);
      expect(find.text('0 Comments'), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);

      // Tap Like
      await tester.tap(find.text('Like'));
      await tester.pump();
      expect(find.text('Liked'), findsOneWidget);

      // Tap Like again
      await tester.tap(find.text('Liked'));
      await tester.pump();
      expect(find.text('Like'), findsOneWidget);

      // Submit empty comment (should not add)
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      expect(find.text('0 Comments'), findsOneWidget);

      // Add valid comment
      await tester.enterText(find.byType(TextField), 'Great photo!');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text('1 Comments'), findsOneWidget);
      expect(find.text('Great photo!'), findsOneWidget);
    });
  });

  group('CreatePostSheet Widget tests', () {
    testWidgets('Empty fields show validation snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreatePostSheet(username: 'TestUser'),
          ),
        ),
      );

      await tester.tap(find.text('Submit Post'));
      await tester.pump();

      expect(find.text('Complete both fields before submitting!'), findsOneWidget);
    });

    testWidgets('Invalid URL shows URL validation snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreatePostSheet(username: 'TestUser'),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Test Caption');
      await tester.enterText(textFields.at(1), 'not-a-valid-url');

      await tester.tap(find.text('Submit Post'));
      await tester.pump();

      expect(find.text('Enter a valid HTTP or HTTPS image URL.'), findsOneWidget);
    });
  });

  group('Full Application Flow tests', () {
    testWidgets('Login -> MainScreen -> Social Media -> Tab Switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(const StudentApp());
      await tester.pumpAndSettle();

      // Enter login credentials
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'admin');
      await tester.enterText(textFields.at(1), 'admin123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // MainScreen opens
      expect(find.text('Home'), findsWidgets);

      // Switch to Social Media tab (index 3)
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      // Verify sample posts
      expect(find.text('JohnDoe'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('JaneSmith'), findsOneWidget);

      // Switch back to Home and then back to Social Media to verify state preservation
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Welcome, Student!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();
      expect(find.text('JohnDoe'), findsOneWidget);
    });
  });
}
