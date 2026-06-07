import 'package:flutter_test/flutter_test.dart';
import 'package:project/common/validators.dart';

void main() {
  group('Validators (SRS FR-3.1/3.6 — constraints)', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('sara@uni.edu'), isNull);
    });

    test('password requires >= 6 chars', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('name must be non-empty', () {
      expect(Validators.name('   '), isNotNull);
      expect(Validators.name('Sara'), isNull);
    });
  });

  group('Password strength (SRS FR-3.1)', () {
    test('classifies by length + variety', () {
      expect('abc'.passwordStrength, PasswordStrength.weak);
      expect('abcdef12'.passwordStrength, PasswordStrength.fair);
      expect('Abcdef12!'.passwordStrength, PasswordStrength.strong);
    });
  });
}
