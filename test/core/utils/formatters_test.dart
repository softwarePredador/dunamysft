import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dunamys/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('Formatters Tests', () {
    group('currency', () {
      test('should format positive values correctly', () {
        final result = Formatters.currency(10.50);
        expect(result.replaceAll('\u00A0', ' '), 'R\$ 10,50');
      });

      test('should format zero correctly', () {
        final result = Formatters.currency(0);
        expect(result.replaceAll('\u00A0', ' '), 'R\$ 0,00');
      });

      test('should format large values correctly', () {
        final result = Formatters.currency(1000000);
        expect(result.replaceAll('\u00A0', ' '), 'R\$ 1.000.000,00');
      });
    });

    group('date', () {
      test('should format date correctly', () {
        final date = DateTime(2025, 12, 16);
        expect(Formatters.date(date), '16/12/2025');
      });

      test('should format date with single digit day and month', () {
        final date = DateTime(2025, 1, 5);
        expect(Formatters.date(date), '05/01/2025');
      });
    });

    group('dateTime', () {
      test('should format datetime correctly', () {
        final date = DateTime(2025, 12, 16, 14, 30);
        expect(Formatters.dateTime(date), '16/12/2025 14:30');
      });
    });

    group('phone', () {
      test('should format mobile phone correctly', () {
        expect(Formatters.phone('11999998888'), '(11) 99999-8888');
      });

      test('should format landline correctly', () {
        expect(Formatters.phone('1133334444'), '(11) 3333-4444');
      });

      test('should return input if invalid length', () {
        expect(Formatters.phone('123'), '123');
      });
    });

    group('cpf', () {
      test('should format CPF correctly', () {
        expect(Formatters.cpf('12345678900'), '123.456.789-00');
      });

      test('should return input if invalid length', () {
        expect(Formatters.cpf('123'), '123');
      });
    });

    group('time', () {
      test('should format time correctly', () {
        final date = DateTime(2025, 12, 16, 14, 30);
        expect(Formatters.time(date), '14:30');
      });

      test('should format time with leading zeros', () {
        final date = DateTime(2025, 12, 16, 9, 5);
        expect(Formatters.time(date), '09:05');
      });
    });
  });
}
