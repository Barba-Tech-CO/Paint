import 'package:flutter_test/flutter_test.dart';
import 'package:painter_pro/utils/auth/token_sanitizer.dart';

void main() {
  group('TokenSanitizer', () {
    group('sanitizeToken', () {
      test('should return null for null input', () {
        expect(TokenSanitizer.sanitizeToken(null), isNull);
      });

      test('should return null for empty string', () {
        expect(TokenSanitizer.sanitizeToken(''), isNull);
        expect(TokenSanitizer.sanitizeToken('   '), isNull);
      });

      test('should trim whitespace and newlines', () {
        const token = '1|abcd1234efgh5678';
        expect(
          TokenSanitizer.sanitizeToken('  $token  '),
          equals(token),
        );
        expect(
          TokenSanitizer.sanitizeToken('\n$token\n'),
          equals(token),
        );
        expect(
          TokenSanitizer.sanitizeToken('\t$token\r\n'),
          equals(token),
        );
      });

      test('should remove wrapping double quotes', () {
        const token = '1|abcd1234efgh5678';
        expect(
          TokenSanitizer.sanitizeToken('"$token"'),
          equals(token),
        );
      });

      test('should remove wrapping single quotes', () {
        const token = '1|abcd1234efgh5678';
        expect(
          TokenSanitizer.sanitizeToken("'$token'"),
          equals(token),
        );
      });

      test('should remove Bearer prefix', () {
        const token = '1|abcd1234efgh5678';
        expect(
          TokenSanitizer.sanitizeToken('Bearer $token'),
          equals(token),
        );
        expect(
          TokenSanitizer.sanitizeToken('bearer $token'),
          equals(token),
        );
        expect(
          TokenSanitizer.sanitizeToken('BEARER $token'),
          equals(token),
        );
      });

      test(
        'should handle complex cases with quotes, Bearer, and whitespace',
        () {
          const token = '1|abcd1234efgh5678';
          expect(
            TokenSanitizer.sanitizeToken('  "Bearer $token"  '),
            equals(token),
          );
          expect(
            TokenSanitizer.sanitizeToken('\n\'bearer $token\'\t'),
            equals(token),
          );
        },
      );

      test('should accept valid Laravel Sanctum tokens', () {
        const sanctumToken = '1|abcd1234efgh5678ijkl9012mnop3456';
        expect(
          TokenSanitizer.sanitizeToken(sanctumToken),
          equals(sanctumToken),
        );
      });

      test('should accept valid JWT-like tokens', () {
        const jwtToken =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        expect(
          TokenSanitizer.sanitizeToken(jwtToken),
          equals(jwtToken),
        );
      });

      test('should reject invalid token formats', () {
        expect(
          TokenSanitizer.sanitizeToken('invalid token with spaces'),
          isNull,
        );
        expect(
          TokenSanitizer.sanitizeToken('token@with#special%chars'),
          isNull,
        );
        expect(TokenSanitizer.sanitizeToken('token/with/slashes'), isNull);
      });

      test('should accept tokens with hyphens, underscores, and dots', () {
        const tokenWithSpecialChars = 'valid-token_with.special-chars_123';
        expect(
          TokenSanitizer.sanitizeToken(tokenWithSpecialChars),
          equals(tokenWithSpecialChars),
        );
      });
    });

    group('isValidTokenFormat', () {
      test('should return false for null or empty strings', () {
        expect(TokenSanitizer.isValidTokenFormat(null), isFalse);
        expect(TokenSanitizer.isValidTokenFormat(''), isFalse);
        expect(TokenSanitizer.isValidTokenFormat('   '), isFalse);
      });

      test('should return true for valid token formats', () {
        expect(
          TokenSanitizer.isValidTokenFormat('1|abcd1234efgh5678'),
          isTrue,
        );
        expect(
          TokenSanitizer.isValidTokenFormat(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
          ),
          isTrue,
        );
      });

      test('should return false for invalid token formats', () {
        expect(TokenSanitizer.isValidTokenFormat('invalid token'), isFalse);
        expect(TokenSanitizer.isValidTokenFormat('token@invalid'), isFalse);
        expect(TokenSanitizer.isValidTokenFormat('token with spaces'), isFalse);
      });
    });
  });
}
