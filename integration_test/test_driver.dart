import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Bond App Authentication Flow', () {
    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      await driver.close();
    });

    test('verifies the login screen shows up', () async {
      // Wait until we find the welcome text to verify we're on the login screen
      await driver.waitFor(find.text('Welcome to Bond'));
      
      // Verify other elements are present on the login screen
      await driver.waitFor(find.text('Sign in to continue'));
      await driver.waitFor(find.text('Login'));
      await driver.waitFor(find.text('Forgot Password?'));
      await driver.waitFor(find.text('Sign Up'));
    });

    test('shows error on invalid email login attempt', () async {
      // Enter invalid email
      await driver.tap(find.byType('TextFormField').at(0));
      await driver.enterText('invalid-email');
      
      // Enter valid password
      await driver.tap(find.byType('TextFormField').at(1));
      await driver.enterText('password123');
      
      // Tap login button
      await driver.tap(find.text('Login'));
      
      // Verify error message appears
      await driver.waitFor(find.text('Please enter a valid email'));
    });

    test('shows error on empty password login attempt', () async {
      // Enter valid email
      await driver.tap(find.byType('TextFormField').at(0));
      await driver.enterText('test@example.com');
      
      // Clear password field
      await driver.tap(find.byType('TextFormField').at(1));
      await driver.enterText('');
      
      // Tap login button
      await driver.tap(find.text('Login'));
      
      // Verify error message appears
      await driver.waitFor(find.text('Please enter your password'));
    });

    // Additional auth flow tests will be added here
  });
}
