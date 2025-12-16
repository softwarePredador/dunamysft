import 'package:flutter_test/flutter_test.dart';
import 'package:dunamys/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('email', () {
      test('should return null for valid emails', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.org'), isNull);
        expect(Validators.email('user+tag@gmail.com'), isNull);
      });

      test('should return error message for invalid emails', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@domain.com'), isNotNull);
      });
    });

    group('password', () {
      test('should return null for valid passwords', () {
        expect(Validators.password('password123'), isNull);
        expect(Validators.password('123456'), isNull);
      });

      test('should return error for passwords less than 6 characters', () {
        expect(Validators.password('12345'), isNotNull);
        expect(Validators.password(''), isNotNull);
        expect(Validators.password('abc'), isNotNull);
      });
    });

    group('phone', () {
      test('should return null for valid phone numbers', () {
        expect(Validators.phone('(11) 99999-8888'), isNull);
        expect(Validators.phone('(11) 3333-4444'), isNull);
      });

      test('should return error for invalid phone numbers', () {
        expect(Validators.phone(''), isNotNull);
        expect(Validators.phone('123'), isNotNull);
      });
    });

    group('cpf', () {
      test('should return null for valid CPF format', () {
        expect(Validators.cpf('12345678901'), isNull);
        expect(Validators.cpf('123.456.789-01'), isNull);
      });

      test('should return error for invalid CPFs', () {
        expect(Validators.cpf(''), isNotNull);
        expect(Validators.cpf('11111111111'), isNotNull);
        expect(Validators.cpf('123'), isNotNull);
      });
    });

    group('required', () {
      test('should return null for non-empty strings', () {
        expect(Validators.required('test'), isNull);
        expect(Validators.required('test value'), isNull);
      });

      test('should return error for empty strings', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required(null), isNotNull);
      });

      test('should include field name in error message', () {
        final result = Validators.required('', fieldName: 'Nome');
        expect(result, contains('Nome'));
      });
    });
  });
}
